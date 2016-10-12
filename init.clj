#!/usr/bin/env boot

(set-env! :dependencies '[[pieterbreed/tappit "0.9.8"]
                          [me.raynes/conch "0.8.0"]
                          [environ "1.0.3"]])


;; ----------------------------------------

;; warnings, drama. we need an unreleased version of clojure for this script
(require 'environ.core)
(when (not (re-find #"1\.9\.0"
                    (or 
                     (environ.core/env :boot-clojure-version)
                     "")))
  (println "# Set ENV variables like this:")
  (println "# $ export BOOT_CLOJURE_VERSION=1.9.0-alpha10")
  (println "Bail out! Requires BOOT_CLOJURE_VERSION=1.9.0-alpha10 or higher")
  (System/exit 0))

;; ----------------------------------------

(require '[tappit.producer :refer [with-tap! ok]])
(require '[me.raynes.conch :as conch])
(require 'boot.core)

;; ----------------------------------------

(defn cmd-is-available
  "Tests whether a UNIX shell command can be found."
  [appname]
  (conch/with-programs [which]
    (let [res (which appname {:throw false
                              :verbose true})]
      (= 0 (deref (:exit-code res))))))

(defn version-of-app-found
  "Runs <command> <-version> and tests the output against a regex"
  [r cmd p]
  (conch/let-programs
      [c cmd]

    (let [res (c p {:throw false
                    :verbose true})
          exit-code (deref (:exit-code res))]
      
      (if (not= 0 exit-code) false
          (boolean (re-find r (:stdout res)))))))

;; ----------------------------------------

;; this trick gets us the absolute, canonical path to
;; the folder this script is located
;; these scripts are executed within the context of where
;; they are on the filesystem.
(let [bsf (-> boot.core/*boot-script* clojure.java.io/file)]
  (def work-dir
    (-> (or (if (.isAbsolute bsf) bsf)
            (clojure.java.io/file (System/getProperty "user.dir")
                                  bsf))
        .getParentFile
        .getCanonicalPath)))

;; ----------------------------------------

(with-tap!

  ;; ----------------------------------------

  (defn bail [ll]
    "Causes this script to terminate with all lines in ll printed via diag!, the first line of ll being called with bail-out! and System/exit afterwards."
    (->> ll (map diag!) dorun)
    (bail-out! (first ll))
    (System/exit 1))

  (defn diag-lines [ll] (->> ll (map diag!) dorun))

  ;; ----------------------------------------

  (if (not (ok! (cmd-is-available "terraform")
                "terraform-is-installed"))
    (bail ["terraform cannot be found"
           "`terraform` has to be discoverable by `which`"]))

  ;; ----------------------------------------

  (diag! (str "Working directory at: " work-dir))
  (diag! "Calling `terraform apply`...")

  (conch/with-programs [terraform]
    (diag-lines (terraform "apply"
                           {:seq true
                            :throw true
                            :verbose false
                            :dir (clojure.java.io/file work-dir "terraform")}))
    (ok! ok "terraform-apply-done")
    (diag-lines (terraform "output" {:seq true
                                     :throw true
                                     :verbose false
                                     :dir (clojure.java.io/file work-dir "terraform")})))

  ;; ----------------------------------------

  (diag! "Running ansible-playbook ... init.yml")
  (diag! "(This step takes long and lacks feedback. Let it finish...)")
  (conch/with-programs [ansible-playbook]
    (let [playbook-folder (clojure.java.io/file work-dir "ansible")
          ansible-proc (ansible-playbook "-i" (.getCanonicalPath
                                               (clojure.java.io/file playbook-folder
                                                                     "inventory.clj"))
                                         (.getCanonicalPath
                                          (clojure.java.io/file playbook-folder
                                                                "init.yml"))
                                         "-c" "paramiko"
                                         {:seq true
                                          :throw false
                                          :verbose true})]
      (diag-lines (-> ansible-proc :proc :out))
      (diag-lines (-> ansible-proc :proc :err))
      (if (not (=! 0 (-> ansible-proc :exit-code deref)
                   "ansible-playbook-init-succeeded"))
        (bail ["Ansible init playbook failed"])))

    ))

#!/usr/bin/env boot

(set-env! :dependencies '[[pieterbreed/ansible-inventory-clj "0.1.1"]
                          [environ "1.0.3"]
                          [org.clojure/data.json "0.2.6"]
                          [me.raynes/conch "0.8.0"]
                          [wharf "0.2.0-SNAPSHOT"]])

;; ----------------------------------------

(require '[ansible-inventory-clj.core :as yinv])
(require '[environ.core :refer [env]])
(require '[clojure.data.json :as json])
(require '[me.raynes.conch :as conch])
(require '[wharf.core :as wharf])

;; ----------------------------------------

(def terraform-folder (env :terraform-path))

(if (nil? terraform-folder)
  (do
    (println "Specify the terraform-path env variable")
    (System/exit 1)))

;; ----------------------------------------

(def data (->> (conch/with-programs [terraform]
                 (terraform "output" "-json" {:dir terraform-folder}))
               json/read-str
               (wharf/transform-keys (comp
                                      keyword
                                      wharf/underscore->hyphen))))

(def worker-nodes (-> data :worker-nodes-public :value))
(def master-nodes (-> data :master-nodes-public :value))

;; ----------------------------------------



(as-> yinv/empty-inventory $

  ;; add details for master nodes
  (->> (for [x master-nodes]
         {:host ["ubuntu" x 22]
          :vars {"ansible_user" "ubuntu"
                 "ansible_host" x}})
       (reduce (fn [acc x]
                 (-> (yinv/add-target acc
                                      (:host x)
                                      (:vars x))
                     (yinv/add-target-to-group (:host x)
                                               "master-nodes")))
               $))

  ;; add details to worker nodes
  (->> (for [x worker-nodes]
         {:host ["ubuntu" x 22]
          :vars {"ansible_user" "ubuntu"
                 "ansible_host" x}})
       (reduce (fn [acc x]
                 (-> (yinv/add-target acc
                                      (:host x)
                                      (:vars x))
                     (yinv/add-target-to-group (:host x)
                                               "worker-nodes")))
               $))
  


  
  ;; (yinv/add-target $ vagrant-host {"ansible_user" "vagrant"
  ;;                                  "ansible_host" (env/env :houstan-hostname)})
  ;; (yinv/add-target-to-group $ vagrant-host "vagrant-hosts")
  ;; (yinv/add-target-to-group $ vagrant-host "java-machines")
  (yinv/make-ansible-list $)
  (json/write-str $)
  (println $))


;; (as-> yinv/empty-inventory $
;;   (->> (for [mstr (-> data :master-nodes-public :value)]
;;          {:host ["ubuntu" mstr 22]
;;           :vars {"ansible_user" "ubuntu"
;;                  "ansible_host" mstr}})
;;        (reduce (fn [acc x]
;;                  (yinv/add-target acc
;;                                   (:host x)
;;                                   (:vars x)))
;;                $))
;;   ;; (yinv/add-target $ vagrant-host {"ansible_user" "vagrant"
;;   ;;                                  "ansible_host" (env/env :houstan-hostname)})
;;   ;; (yinv/add-target-to-group $ vagrant-host "vagrant-hosts")
;;   ;; (yinv/add-target-to-group $ vagrant-host "java-machines")
;;   (yinv/make-ansible-list $)
;;   (json/write-str $)
;;   (println $))


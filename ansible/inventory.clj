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
    (println "Specify the TERRAFORM_PATH env variable")
    (System/exit 1)))

(let [tf (clojure.java.io/file terraform-folder)]
  (if (not (.exists tf))
    (do
      (println (str "'" terraform-folder "' does not exist."))
      (System/exit 1))))

;; ----------------------------------------

(def terraform-output
  (try
    (conch/with-programs [terraform]
      (terraform "output" "-json" {:dir terraform-folder}))
    (catch Exception e
      (do 
        (println (str "terraform has no output: "
                      (->> (ex-data e)
                           :proc
                           :err
                           (reduce str))))
        (System/exit 1)))))

(def data (->> terraform-output
               json/read-str
               (wharf/transform-keys (comp
                                      keyword
                                      wharf/underscore->hyphen))))

(letfn [(get [k]
          (-> data k :value))]
  (def worker-nodes (get :worker-nodes-public))
  (def master-nodes (get :master-nodes-public))
  (def datomic-nodes (get :datomic-nodes-public))
  (def master-nodes-pvt (get :master-nodes-private)))

;; ----------------------------------------



(as-> yinv/empty-inventory $

  ;; this makes the INTERNAL DNS names of the master
  ;; nodes available to the worker nodes
  ;; this will be used when the nomad config is being set up
  ;; so the nomad workers knows who their masters are
  (yinv/add-group $ "worker-nodes" {"master_nodes_internal_dns" master-nodes-pvt})
  (yinv/add-group $ "master-nodes" {"master_nodes_internal_dns" master-nodes-pvt})
  (yinv/add-group $ "static-consul-nodes" {"master_nodes_internal_dns" master-nodes-pvt})
  (yinv/add-group $ "datomic-nodes"
                  {"datomic_transactor_properties"
                   {"protocol" "ddb"
                    "host" "0.0.0.0"
                    "alt-host" "datomic.service.consul"
                    "port" "4334"
                    "license-key" "BAD_LICENSE_KEY"
                    "memory-index-threshold" "32m"
                    "memory-index-max" "256m"
                    "object-cache-max" "128m"
                    "data-dir" "/var/lib/datomic"
                    "log-dir" "/var/log/datomic"
                    "pid-file" "/var/run/datomic/datomic_transactor.pid"}}
                  )

  ;; add master nodes
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

  ;; add worker nodes
  (->> (for [x worker-nodes]
         {:host ["ubuntu" x 22]
          :vars {"ansible_user" "ubuntu"
                 "ansible_host" x}})
       (reduce (fn [acc x]
                 (-> (yinv/add-target acc
                                      (:host x)
                                      (:vars x))
                     (yinv/add-target-to-group (:host x)
                                               "worker-nodes")
                     (yinv/add-target-to-group (:host x)
                                               "java-nodes")
                     (yinv/add-target-to-group (:host x)
                                               "docker-nodes")))
               $))
  
  ;; add datomic nodes
  (->> (for [x datomic-nodes]
         {:host ["ubuntu" x 22]
          :vars {"ansible_user" "ubuntu"
                 "ansible_host" x}})
       (reduce (fn [acc x]
                 (-> (yinv/add-target acc
                                      (:host x)
                                      (:vars x))
                     (yinv/add-target-to-group (:host x)
                                               "datomic-nodes")
                     (yinv/add-target-to-group (:host x)
                                               "java-nodes")
                     (yinv/add-target-to-group (:host x)
                                               "static-consul-nodes")))
               $))
  


  
  (yinv/make-ansible-list $)
  (json/write-str $)
  (println $))

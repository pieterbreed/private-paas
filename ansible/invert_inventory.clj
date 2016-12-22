#!/usr/bin/env boot

;; - Reads an ansible dynamic inventory script's json output from stdin.
;; - Then pivots the inventory, to produce a dictionary that maps machine-name -> groups-belonged-to
;; - This is useful for serverspec, which can tests each host, against each role (group) it belongs to.

(set-env! :dependencies '[[org.clojure/data.json "0.2.6"]])

;; ----------------------------------------

(require '[clojure.data.json :as json])

;; ----------------------------------------

(def INPUT (json/read-str (slurp *in*)))

(defn flatten-machines-from-children-groups [d]
  (for [g (keys d)
        chg (get-in d [g "children"])
        m (get-in d [chg "hosts"])]
    (hash-map :group g :machine m)))

(defn flatten-to-pairs [d]
  ;; ignore the key "_meta" because that's meta information
  (for [g (keys d)
        m (get-in d [g "hosts"])]
    (hash-map :group g :machine m)))

(defn roll-up-group-names [d]
  (into {}
        (for [m (keys d)] 
          (hash-map m 
                    (->> (get d m)
                         (map :group)
                         set
                         vec
                         (hash-map :groups))))))

;; ----------------------------------------

;; read json from ansible dynamic inventory output, from STDIN
(as-> INPUT $

  ;; drop host meta-information identified by a special hostname 
  (dissoc $ "_meta")

  ;; flatten the data into "pairs" eg {:group "group-name" :machine "machine-name"}
  (concat 
   (flatten-to-pairs $)
   (flatten-machines-from-children-groups $))

  ;; scrape together by machine
  (group-by :machine $)

  ;; for each machine, unroll the grouped pairs into a list of group names
  (roll-up-group-names $)

  ;; -> json & stdout
  (json/write-str $)
  (println $))


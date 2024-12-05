#!/usr/bin/env bb
;; -*- clojure -*-
;; vim: set filetype=clojure:
(require
 '[babashka.cli :as cli]
 '[babashka.fs :as fs]
 '[babashka.process :refer [sh]])

;; ① Enter script directory
;; ?

;; ② Parse arguments

(def cli-spec
  {:spec
   {:list-dir {:desc "Directory to list"
               :default "test"}
    :no-color {:desc "Disable color output"
               :coerce :boolean
               :default false}
    :help {:desc "Show help"
           :alias :h
           :coerce :boolean}}})

(defn show-help
  [spec]
  (println "Usage: ./sample.bb [options]")
  (println)
  (println "Options:")
  (cli/format-opts (merge spec {:order (vec (keys (:spec spec)))})))

;; ③ Get file list

(defn get-file-list [dir]
  (->> (file-seq (fs/file dir))
       (filter fs/regular-file?)))

;; ④ Split file names

(defn get-filename [file]
  (-> file fs/file-name fs/strip-ext))

;; ⑤ Categorize files by extension

(defn categorize-files-by-extension [file-list]
  (group-by fs/extension file-list))

;; ⑥ Get a random number

;; Not needed, we can use `rand-nth` to select random item

;; ⑦ Search text in a file

(defn search-text-in-file [file text]
  (zero? (:exit (sh "grep" text file))))

;; ⑧ Print results

(def yellow "\033[33m")
(def blue "\033[34m")
(def light-red "\033[91m")
(def light-green "\033[92m")
(def light-cyan "\033[96m")
(def magenta-bg "\033[45m")
(def color-reset "\033[0m")

(defn make-printer [use-color]
  (if use-color
    (fn [prefix [color text]]
      (printf "%s%s%s%s\n" prefix color text color-reset))
    (fn [prefix [_ text]]
      (printf "%s%s\n" prefix text))))

(defn print-category [print-fn extension filenames]
  (print-fn "Extension: " [blue extension])
  (print-fn "Count: " [light-cyan (str (count filenames))])
  (println "Files: ")
  (doseq [filename filenames]
    (print-fn "  " [magenta-bg (get-filename filename)]))
  (println))

(defn print-search [print-fn search-result]
  (print-fn "Search file: " [yellow (:search-file search-result)])
  (print-fn "Has search text: "
            (if (:has-search-text search-result)
              [light-green "yes"]
              [light-red "no"])))

;; Main function

(def opts (cli/parse-opts *command-line-args* cli-spec))

(when (or (:help opts) (:h opts))
  (println (show-help cli-spec))
  (System/exit 0))

(def print-fn (make-printer (not (:no-color opts))))
(def file-list (get-file-list (:list-dir opts)))

(let [categorized-files (categorize-files-by-extension file-list)]
  (doseq [[extension filenames] (sort-by key categorized-files)]
    (print-category print-fn extension filenames)))

(let [search-file (rand-nth file-list)
      has-search-text (search-text-in-file search-file "monzool")
      search-result {:search-file search-file
                     :has-search-text has-search-text}]
  (print-search print-fn search-result))

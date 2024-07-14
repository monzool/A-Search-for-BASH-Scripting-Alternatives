#!/usr/bin/env janet

(import sh)
(import spork/argparse :prefix "")


# ① Enter script directory
# ?


# ② Parse arguments

(def argparse-params
  ["Usage: ./sample.janet [options]"
   "list-dir" {:kind :option
               :help "Directory to list. Default: test"
               :default "test"}
   "no-color" {:kind :flag
               :help "Disable color output. Default: false"
               :default false}])


# ③ Get file list

(defn get-file-list [dir]
  (->> (sh/$< find ,dir -type f)
    (string/split "\n")
    (filter (fn [x] (not (empty? x))))))


# ④ Split file names

(defn get-extension [file]
  (->> file
      (string/split ".")
      (last)))

(defn get-filename [file]
  (->> 
    (string/split "/" file)
    (last) 
    (string/split ".")
    (first)))


# ⑤ Categorize files by extension

(defn categorize-files-by-extension [file-list]
  (let [file-categories @{}]
    (each file file-list
      (let [filename (get-filename file)
            extension (get-extension file)]
        (if (not (has-key? file-categories extension))
          (set (file-categories extension) @[filename])
          (array/concat (get file-categories extension) @[filename]))))
    file-categories))


# ⑥ Get a random number

(defn get-random-number [max]
  (with [f 
    (file/open "/dev/urandom")]
    (def output @"")
    (sh/run od -vAn -N2 -tu2 < ,f | tr -d `[:space:]` > ,output)
    (-> output
      (scan-number)
      (% max))))


# ⑦ Search text in a file

(defn search-text-in-file [file text]
  (let [[result] (sh/run grep ,text ,file)]
    (if (= result 0)
        true
        false)))


# ⑧ Print results

(def yellow "\e[33m")
(def blue "\e[34m")
(def light_red "\e[91m")
(def light_green "\e[92m")
(def light_cyan "\e[96m")
(def magenta_bg "\e[45m")
(def color_reset "\e[0m")

(defn make-printer [use_color]
  (fn [prefix [color text]]
    (if use_color
      (print (string/format "%s%s%s%s" prefix color text color_reset))
      (print (string/format "%s%s" prefix text)))))

(defn print-category [print-fn extension filenames]
  (print-fn "Extension: " [blue extension])
  (print-fn "Count: " [light_cyan (string (length filenames))])
  (print "Files: ")
  (each filename filenames
    (print-fn "  " [magenta_bg filename]))
  (print))

(defn print-search [print-fn search-result]
  (print-fn "Search file: " [yellow (get search-result :search-file)])
  (print-fn "Has search text: "
    (if (get search-result :has-search-text)
      [light_green "yes"] 
      [light_red "no"])))


# Main function

(defn main [&]
  (def options (argparse ;argparse-params))
  (unless options
    (os/exit 1))

  (def print-fn (make-printer (not (get options "no-color"))))

  (def list-dir (get options "list-dir"))
  (def file-list (get-file-list list-dir))

  (def categorized-files (categorize-files-by-extension file-list))
  (loop [[extension filenames] :pairs categorized-files]
    (print-category print-fn extension filenames))


  (let [random-number (get-random-number (length file-list))
        search-file (get file-list random-number)
        has-search-text (search-text-in-file search-file "monzool")
        search-result (struct :search-file search-file
                              :has-search-text has-search-text)]
  (print-search print-fn search-result)))


#!/usr/bin/env nu


# ① Enter script directory
# ?


# ② Parse arguments
#=> ref ②


# ③ Get file list

def get_file_list [dir: string] : list {
    let file_list = ^find $dir -type f | complete | get stdout | lines
    let non_empty_file_list = $file_list | filter { |file| $file | is-not-empty }
    return $non_empty_file_list
}


# ④ Split file names
#=> ref ④


# ⑤ Categorize files by extension
#=> ref ⑤


# ⑥ Get a random number

def get_random_number [max: int] : int {
    random int 1..<($max)
}


# ⑦ Search text in a file

def search_text_in_file [filename: string, text: string] : bool {
    (^grep $text $filename | complete | get exit_code) == 0
}


# ⑧ Print results

def color_print [use_color: bool] {
    { | color, prefix, text |
        print -n $prefix
        if $use_color {
            $"(ansi $color)($text)" | print
        } else {
            print $text
        }

        if $use_color {
            $"(ansi reset)" | print -n
        }
    }
}

def print_category [print_fn: closure, extension: string, filenames: list] : void {
    do $print_fn "blue" "Extension: " $extension
    let count = $filenames | length
    do $print_fn "light_blue" "Count: " $count

    "Files:" | print
    $filenames | each { |filename| do $print_fn "purple" "  " $filename }

    "" | print
}

def print_search [print_fn: closure, search_result] : void {
    let filename = $search_result.filename
    let found = $search_result.found

    $"Search result:" | print
    do $print_fn "yellow" "  File: " $filename
    do $print_fn (if $found { "green" } else { "red" }) $"  Found: " $found

    "" | print
}


# Main function

def main [
    # ②
    --list-dir: string = "test",    # Directory to list
    --no-color                      # Disable color output. (default: false)
    ] {

    let color_print_fn = (color_print (not $no_color))
    let file_list = get_file_list $list_dir


    # Categories
    let file_categories = $file_list | group-by { path parse | get extension } # ⑤
    $file_categories | transpose key value | each { |category|
        # ④
        let extension = $category.key
        let filenames = $category.value | path parse | get stem
        { $extension: $filenames }
        print_category $color_print_fn $extension $filenames
    }

    # Search
    let random_number = get_random_number ($file_list | length)
    let search_file = $file_list | get $random_number
    let has_search_match = search_text_in_file $search_file "monzool"
    let search_result = { filename: $search_file, found: $has_search_match}
    print_search $color_print_fn $search_result
}


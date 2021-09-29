#!/bin/bash
fix_file=${1:-fubar.ipynb}
find_string='\\newcommand{\\'

function replace_commands {
  echo "Finding $find_string" && echo

  # find the new command lines in the notebook
  grep -i $find_string $fix_file | while read line ; do
    # find the one they put in 
    new_cmd=$(echo $(echo $line | cut -d "{" -f2) | \
      cut -d "}" -f1)

    # Find the katex compatible string
    original_cmd=$(echo $(echo $(echo $line | cut -d "{" -f3) | \
      cut -d "}" -f1) | cut -d "(" -f1)

    if [[ $new_cmd == "\\softmax" ]]; then
      echo softmax
      original_cmd='\operatorname{softmax}'
    else if [[ $new_cmd == "\\given" ]]; then
      echo given
      original_cmd='\\,|\\\\,'
      fi
    fi
    echo "Replacing $new_cmd with $original_cmd"

    sed -i "s/\\$new_cmd/\\$original_cmd/g" $fix_file

    # argmax is different
    if [[ $new_cmd == "\\argmax" ]]; then
      echo argmax
      add='{\\\\operatorname{argmax}}'
      underset='\underset{.*}'
      sed -i "s/$underset/&$add/g" $fix_file
    fi

    # sed -i "s/\\$new_cmd/\\$original_cmd/g" fix_file
  done
}

# repl (str, rpl) {
#   sed -i `s/$str/$rpl/g` $1
# }
echo "backup $fix_file in case of corruption"
find . -name "$(echo $fix_file)" -exec cp "{}" "{}.bak" \; && \
replace_commands
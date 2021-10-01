#!/bin/bash
fix_file=${1:-fubar.ipynb}
run_fix=${2:-False}

## Revert command ##
function fix {
  cp "$fix_file.bak" $fix_file
}

## Makes the file pretty for replace_commands ##
function pretty_file {
  # pretty-print to new file
  # same file would write as it reads (?!)
  python -mjson.tool $fix_file > "$fix_file.new" && \
  mv "$fix_file.new" $fix_file
}

## Finds and Replaces commands ##
function replace_commands {
  find_string='\\newcommand{\\'
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

  done
}

## Holds management logic ##
function main {
  if [[ $fix_file == "fubar.ipynb" ]]; then
    echo "Usage: bash fix.sh <file-name>"
    echo "To revert to original: bash fix.sh <file-name> revert"
    return -1
  fi

  if [[ $run_fix == "revert" ]]; then
    echo Running $run_fix ...
    fix;
    return 0
  fi

  echo "backup $fix_file in case of corruption"
  find . -name "$(echo $fix_file)" -exec cp "-n" "{}" "{}.bak" \;

  pretty_file && \
  replace_commands
  return 0
}

main
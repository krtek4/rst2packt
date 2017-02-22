#!/bin/bash

BASE="$(cd "$( dirname "$0" )" && pwd)"
FILE=$(realpath $1)
OUTPUT=$(realpath $2)

# move to the src directory so that require work correctly with __DIR__
cd $(dirname $FILE)

echo "<?php" > "$OUTPUT"

cat "$FILE" | (
  while IFS='' read -r line; do
    # code sent to PHP
    if [ "$line" == "<?php" ]; then
      SEND_TO_PHP=true
    fi
    if [ "$line" == "?>" ]; then
      SEND_TO_PHP=false
      echo ";" # in order to correctly close the block Boris needs this
    fi

    if [ "$SEND_TO_PHP" == true -a "${line/'('/}" != "<?php" ]; then
      if [[ "$line" == *sleep* ]]; then
        echo "";
      else
        echo "$line";
      fi
    fi
  done | $BASE/boris.php 2>&1 ) >> "$OUTPUT" 2>&1

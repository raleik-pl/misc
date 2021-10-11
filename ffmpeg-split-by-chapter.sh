#!/bin/bash
# Author: http://crunchbang.org/forums/viewtopic.php?id=38748#p414992
# m4bronto

#     Chapter #0:0: start 0.000000, end 1290.013333
#       first   _     _     start    _     end

while [ $# -gt 0 ]; do

ffmpeg -i "$1" 2> tmp.txt

while read -r first _ _ start _ end; do
  if [[ $first = Chapter ]]; then
    read  # discard line with Metadata:
    read _ _ chapter

    ffmpeg -vsync 2 -i "$1" -ss "${start%?}" -to "$end" -vn -acodec flac "$chapter.flac" </dev/null

  fi
done <tmp.txt

rm tmp.txt

shift
done

#!/bin/bash

if [ ! -d $1 ]; then
    echo "Not a directory: $1"
    exit -1
fi
icons_dir=$(cd -P -- "$(dirname -- "$0")/icons" && pwd -P)

#trap 'ps -o pid= --ppid `ps -o pid= --ppid $$` | xargs kill -9; exit 0' 2;
#trap 'pkill $(pgrep lessapp.sh | sed -e "s/^/ -P /"| tr -d "\n");exit 0' 1 2 3 15;
#trap 'echo $(pgrep lessapp.sh)' 2;
#trap 'ps -o pid= --ppid `ps -o pid= --ppid $$` | xargs kill -9'1 2 3 15;
trap 'pkill -P $(ps -o pid= --ppid $$ | head -1);exit 0' 1 2 3 15;

while read line; do
  filename="$(basename $line)"
  path="$(dirname $line)"

  for files in `ls $path`; do
    if [ "${files##*.}" != "less" ]; then
      continue
    fi;

    # Add compress option min.less files
    if [ `echo $files | rev | cut -f-2 -d. | rev` == "min.less" ]; then
      option="-compress"
    fi;

    # lessc MODIFIED file and file including "@import MODIFIED"
    if [ "$files" == "$filename" -o -n "`cat ${path}/${files} | grep "@import" | grep ${filename%.*}`" ]; then
      lessc $option ${path}/${files} > \
       "${path}/../css/${files%.*}.css" \
        && notify-send "Compile Completed" "$files $num" -i $icons_dir/less.png \
        || notify-send "Compile Error" "$files $num" -i $icons_dir/less.png;
    fi;
  done


done < <(inotifywait -r -q -m -e CLOSE_WRITE --format '%w%f' $1)
#!/bin/bash

for dir in dotfiles/*/
do
    dir=${dir%*/}
    dir="${dir##*/}"
    #echo "$dir"
    rsync -a ~/.config/$dir dotfiles/ --delete
done

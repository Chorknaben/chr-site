#!/bin/bash
echo "Coffeescript autocompile: coffee"
coffee -b -cw content code &
echo "Less autocompile"
while inotifywait -e modify,close_write,moved_to,create less/ ; do
    echo "Less: autocompile triggered"
    cat less/* > general.less
    recess general.less --compile > general.css
done

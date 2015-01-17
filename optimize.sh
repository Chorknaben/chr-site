#!/bin/zsh
CLOSURE_COMPILER_LOCATION="/home/svt/code/html/closure-compiler/compiler.jar"
CLOSURE_CMD="$(which java) -jar $CLOSURE_COMPILER_LOCATION"
USING_JS_FILES=(
    "code/jquery-1.11.1.min.js"
    "code/jqcol.js"
    "code/jquery.morecustoms.js"
    "code/jquery.scrollTo.min.js"
    "code/clndr.js"
    "code/moment.min.js"
    "code/underscore.js"
    "code/jquery.newsTicker.min.js"
)

echo "Optimize CSS"
cat less/* > general.less
recess reset.css general.less --compile --compress > general.css

echo "Compiling Coffee"
coffee -c code content

echo "Concatentating JS"
[ -f deploy.js ] && rm deploy.js
for i in $USING_JS_FILES; do
    cat $i >> deploy.js
done;

echo "Compiling JS Libs"
eval "$CLOSURE_CMD --js deploy.js --js_output_file code/libs.js 2>&1 >/dev/null"
rm deploy.js

#for i in $(ls -1 content | grep .js); do
#    eval "$CLOSURE_CMD --js content/$i --js_output_file content/$i 2>&1 >/dev/null"
#done


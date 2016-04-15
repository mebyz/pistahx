VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else

cd $prj/distrib/
if [ "$mode" = "build" ] ; then
echo "$VERT" "#ORMS: installing distribution dependencies" "$NORMAL"
npm install

npm install -g microtime
npm install -g sqlite3
npm install -g git://github.com/RuntimeTools/appmetrics
npm install -g appmetrics-elk

echo "$VERT" "#ORMS: cloning clemos/haxe-js-kit" "$NORMAL"
rm -rf haxe-js-kit/
git clone https://github.com/clemos/haxe-js-kit.git haxe-js-kit
fi

echo "$VERT" "#ORMS: Haxe transpilation" "$NORMAL"
haxe build.hxml
if [ "$?" != "0" ] ; then
exit 1
fi
cd -

echo "$VERT" "#ORMS: your project output will reside in ./distrib/out/" "$NORMAL"
#rm -rf $prj/distrib/out
rm -rf $prj/distrib/out/app.js
mkdir -p $prj/distrib/out 2>/dev/null || :
cp -rf $prj/app/api.yaml $prj/distrib/out/ 2>/dev/null || :
#cp -rf $prj/distrib/package.json $prj/distrib/out/ 2>/dev/null || :
cp -rf $prj/distrib/api.js $prj/distrib/out/app.js 2>/dev/null || :
cp -rf $prj/distrib/node_modules $prj/distrib/out/ 2>/dev/null || :
cp -rf $prj/node_modules/orms/doc $prj/distrib/out/ 2>/dev/null || :
cp -rf $prj/site $prj/distrib/out/ 2>/dev/null || :
cp -rf $prj/app/conf $prj/distrib/out/ 2>/dev/null || :
cp -rf $prj/app/Business/sql $prj/distrib/out/ 2>/dev/null || :
cp -rf $prj/db.sqlite $prj/distrib/out/ 2>/dev/null || :
cp -rf $prj/.ebignore $prj/distrib/out/ 2>/dev/null || :
mkdir $prj/distrib/out/doc
cp -rf $prj/node_modules/pistahx/doc/* $prj/distrib/out/doc/
fi

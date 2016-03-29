VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else

cd $prj/distrib/
if [ "$mode" = "build" ] ; then
echo "$VERT" "#ORMS: installing distribution dependencies" "$NORMAL"
npm install
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
rm -rf $prj/distrib/out
mkdir $prj/distrib/out
cp -rf $prj/app/api.yaml $prj/distrib/out/api.yaml
cp -rf $prj/distrib/api.js $prj/distrib/out/
cp -rf $prj/distrib/node_modules $prj/distrib/out/
cp -rf $prj/node_modules/orms/doc $prj/distrib/out/
cp -rf $prj/site $prj/distrib/out/
cp -rf $prj/app/conf $prj/distrib/out/
cp -rf $prj/app/Business/sql $prj/distrib/out/
cp -rf $prj/db.sqlite $prj/distrib/out/

fi

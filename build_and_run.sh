VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

# SHOULD BE CALLED FROM YOUR PROJECT's run.sh 
# ORMS IS MEANT TO BE USED AS A DEPENDENCY ! (see readme)

echo "$VERT" "#ORMS: running in mode:$mode" "$NORMAL"
if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else
if [ "$mode" = "build" ] ; then 
echo "$VERT" "#ORMS: installing nodejs dependencies" "$NORMAL"
npm install
echo "$VERT" "#ORMS: installing Haxe dependencies" "$NORMAL"
haxelib install ./gen/libs.hxml
echo "$VERT" "#ORMS: cleaning workspace" "$NORMAL"
rm -rf $prj/distrib/promhx
rm -rf $prj/distrib/haxe-js-kit
rm -rf $prj/distrib/api.js
mkdir -p $prj/distrib/
mkdir -p $prj/distrib/src/
echo "$VERT" "#ORMS: preparing distrib folder" "$NORMAL"
cp -rf ./gen/build.hxml $prj/distrib/build.hxml
cp -rf ./gen/package.json $prj/distrib/package.json
cp -rf ./gen/README.md $prj/distrib/README.md
echo "$VERT" "#ORMS: codegen from yaml to haxe" "$NORMAL"
prj=$prj ./gen/codegen.sh
fi
echo "$VERT" "#ORMS: building from haxe to target" "$NORMAL"
prj=$prj ./gen/build.sh
echo "$VERT" "#ORMS: generating haxe doc (dox)" "$NORMAL"
cd $prj/distrib/
haxelib run dox -i xml
echo "$VERT" "#ORMS: trying to start API" "$NORMAL"
node api.js
fi

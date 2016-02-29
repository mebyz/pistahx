# SHOULD BE CALLED FROM YOUR PROJECT's run.sh 
# ORMS IS MEANT TO BE USED AS A DEPENDENCY ! (see readme)
echo "#ORMS: running in mode:$mode"
if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else
if [ "$mode" = "build" ] ; then 
echo "#ORMS: installing nodejs dependencies"
npm install
echo "#ORMS: installing Haxe dependencies"
haxelib install ./gen/libs.hxml
echo "#ORMS: cleaning workspace"
rm -rf $prj/distrib/promhx
rm -rf $prj/distrib/haxe-js-kit
rm -rf $prj/distrib/api.js
mkdir -p $prj/distrib/
mkdir -p $prj/distrib/src/
echo "#ORMS: preparing distrib folder"
cp -rf ./gen/build.hxml $prj/distrib/build.hxml
cp -rf ./gen/package.json $prj/distrib/package.json
cp -rf ./gen/README.md $prj/distrib/README.md
echo "#ORMS: codegen from yaml to haxe"
prj=$prj ./gen/codegen.sh
fi
echo "#ORMS: building from haxe to target"
prj=$prj ./gen/build.sh
echo "#ORMS: generating haxe doc (dox)"
cd $prj/distrib/
haxelib run dox -i xml
echo "#ORMS: trying to start API"
node api.js
fi

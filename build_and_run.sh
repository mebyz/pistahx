# SHOULD BE CALLED FROM YOUR PROJECT's run.sh 
# ORMS IS MEANT TO BE USED AS A DEPENDENCY ! (see readme)
if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else
if [ "$mode" = "build" ] ; then 
npm install
haxelib install ./gen/libs.hxml
rm -rf $prj/distrib/promhx
rm -rf $prj/distrib/haxe-js-kit
rm -rf $prj/distrib/api.js
mkdir -p $prj/distrib/
mkdir -p $prj/distrib/src/
cp -rf ./gen/build.hxml $prj/distrib/build.hxml
cp -rf ./gen/package.json $prj/distrib/package.json
cp -rf ./gen/README.md $prj/distrib/README.md
prj=$prj ./gen/codegen.sh
fi
prj=$prj ./gen/build.sh
cd $prj/distrib/
haxelib run dox -i xml
node api.js
fi

# SHOULD BE CALLED FROM YOUR PROJECT's run.sh 
# ORMS IS MEANT TO BE USED AS A DEPENDENCY ! (see readme)
npm install
if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else
haxelib install ./gen/libs.hxml
rm -rf $prj/distrib/promhx
rm -rf $prj/distrib/haxe-js-kit
rm -rf $prj/distrib/api.js
prj=$prj ./gen/codegen.sh
prj=$prj ./gen/build.sh
cd $prj/distrib/
haxelib run dox -i xml
node api.js
fi

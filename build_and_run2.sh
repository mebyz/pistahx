VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

# SHOULD BE CALLED FROM YOUR PROJECT's run.sh 
# ORMS IS MEANT TO BE USED AS A DEPENDENCY ! (see readme)

echo "$VERT" "#ORMS (TS TARGET) : running in mode:$mode" "$NORMAL"
if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else

if [ "$mode" = "build" ] ; then 
echo "$VERT" "#ORMS: installing nodejs dependencies" "$NORMAL"
npm install
echo "$VERT" "#ORMS: updating nodejs dependencies" "$NORMAL"
npm update

echo "$VERT" "#ORMS: installing Haxe dependencies" "$NORMAL"

# we are disabling this for now (manual step blocking a full automatic build)
# no problem to run it manually upon first build.)
# haxelib install ./gen/libs.hxml

echo "$VERT" "#ORMS: cleaning workspace" "$NORMAL"
rm -rf $prj/distrib2/
mkdir -p $prj/distrib2/
mkdir -p $prj/distrib/src/
echo "$VERT" "#ORMS: preparing distrib folder" "$NORMAL"
cp -rf ./gen2/package.json $prj/distrib2/package.json
cp -rf ./gen2/typings.json $prj/distrib2/typings.json
cp -rf ./gen2/README.md $prj/distrib2/README.md
fi

echo "$VERT" "#ORMS: codegen from yaml to ts" "$NORMAL"
prj=$prj ./gen2/codegen.sh

if [ "$?" != "0" ] ; then
echo "$ROUGE" "#ORMS: ERROR when generating Typescript code from yaml" "$NORMAL"
exit 1
fi

echo "$VERT" "#ORMS: building from Typescript to target" "$NORMAL"
mode=$mode prj=$prj ./gen2/build.sh

if [ "$?" != "0" ] ; then
echo "$ROUGE" "#ORMS: ERROR when transpiling Typescript code to target" "$NORMAL"
exit 1
fi

if [ "$mode" = "run" ] ; then
echo "$VERT" "#ORMS: trying to start API" "$NORMAL"
cd $prj/distrib2/
node api2.js
fi

fi

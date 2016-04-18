VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

# SHOULD BE CALLED FROM YOUR PROJECT's run.sh 
# PISTAHX IS MEANT TO BE USED AS A DEPENDENCY ! (see readme)

echo "$VERT" "#PISTAHX: running in mode:$mode" "$NORMAL"
if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else

if [ "$mode" = "build" ] ; then 
echo "$VERT" "#PISTAHX: installing nodejs dependencies" "$NORMAL"
npm install
echo "$VERT" "#PISTAHX: updating nodejs dependencies" "$NORMAL"
npm update

echo "$VERT" "#PISTAHX: installing Haxe dependencies" "$NORMAL"

# we are disabling this for now (manual step blocking a full automatic build)
# no problem to run it manually upon first build.)
# haxelib install ./gen/libs.hxml

echo "$VERT" "#PISTAHX: cleaning workspace" "$NORMAL"
rm -rf $prj/distrib/promhx
rm -rf $prj/distrib/haxe-js-kit
rm -rf $prj/distrib/api.js
mkdir -p $prj/distrib/
mkdir -p $prj/distrib/src/
echo "$VERT" "#PISTAHX: preparing distrib folder" "$NORMAL"
fi

echo "$VERT" "#PISTAHX: refresh Main.hx file" "$NORMAL"
cp -rf ./gen/Main.hx $prj/distrib/src/Main.hx

if [ "$mode" = "build" ] ; then
cp -rf ./gen/build.hxml $prj/distrib/build.hxml
cp -rf ./gen/package.json $prj/distrib/package.json
cp -rf ./gen/README.md $prj/distrib/README.md
fi


echo "$VERT" "#PISTAHX: add Dockerfile and deploy script to application" "$NORMAL"
cp ./gen/Dockerfile $prj/
cp ./gen/docker.sh $prj/

rm -rf $prj/distrib/api.js

echo "$VERT" "#PISTAHX: building from haxe to target" "$NORMAL"
mode=$mode prj=$prj ./gen/build.sh

if [ "$?" != "0" ] ; then
echo "$ROUGE" "#PISTAHX: ERROR when transpiling Haxe code to target" "$NORMAL"
exit 1
fi

if [ "$mode" = "build" ] ; then
echo "$VERT" "#PISTAHX: generating haxe doc (dox)" "$NORMAL"
cd $prj/distrib/
haxelib run dox -i xml -o ./out/pages
cd ..
fi

#if [ "$mode" = "run" ] ; then
#echo "$VERT" "#PISTAHX: trying to start API" "$NORMAL"
#cd $prj/distrib/out
#node app.js
#fi

if [ "$mode" = "docker" ] ; then
echo "$VERT" "#PISTAHX: trying to dockerise, and start API" "$NORMAL"
cd $prj/
./docker.sh
fi

fi

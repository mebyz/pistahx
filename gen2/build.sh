VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else

cd $prj/distrib2/
if [ "$mode" = "build" ] ; then

npm install
typings install
tsc server.ts

if [ "$?" != "0" ] ; then
exit 1
fi
cd -
fi

fi
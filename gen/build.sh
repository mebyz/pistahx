VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else

cd $prj/distrib/
if [ "$mode" = "build" ] ; then
echo "$VERT" "#PISTAHX: installing distribution dependencies" "$NORMAL"
npm install

npm install -g microtime
npm install -g sqlite3
npm install -g git://github.com/RuntimeTools/appmetrics
npm install -g appmetrics-elk

echo "$VERT" "#PISTAHX: cloning mebyz/haxe-js-kit (fork of clemo's)" "$NORMAL"
rm -rf haxe-js-kit/
git clone https://github.com/mebyz/haxe-js-kit.git haxe-js-kit
fi
fi
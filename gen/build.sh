VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"

if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else
cd $prj/distrib/
echo -e "$VERT" "#ORMS: installing distribution dependencies" "$NORMAL"
npm install
echo -e "$VERT" "#ORMS: cloning clemos/haxe-js-kit" "$NORMAL"
rm -rf haxe-js-kit/
git clone https://github.com/clemos/haxe-js-kit.git haxe-js-kit
echo -e "$VERT" "#ORMS: Haxe transpilation" "$NORMAL"
haxe build.hxml
cd -
fi

if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else
cd $prj/distrib/
echo "#ORMS: installing distribution dependencies"
npm install
echo "#ORMS: cloning clemos/haxe-js-kit"
rm -rf haxe-js-kit/
git clone https://github.com/clemos/haxe-js-kit.git haxe-js-kit
echo "#ORMS: Haxe transpilation"
haxe build.hxml
cd -
fi

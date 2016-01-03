if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else
cd $prj/distrib/
npm install
rm -rf haxe-js-kit/
git clone https://github.com/clemos/haxe-js-kit.git haxe-js-kit
haxe build.hxml
cd -
fi

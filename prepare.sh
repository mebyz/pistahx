root="./"
mode="build"
prj="../../"

if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else 
		
		if [ "$mode" = "build" ] ; then 
			echo "$VERT" "#PISTAHX: installing nodejs dependencies" "$NORMAL"
			npm install
			echo "$VERT" "#PISTAHX: updating nodejs dependencies" "$NORMAL"
			npm update
			
            echo "$VERT" "#PISTAHX: setting OpenApi Doc UI folder" "$NORMAL"
			mkdir -p ./doc
			cp -rf ./node_modules/swagger-ui/dist/* ./doc/

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
			cp -rf ./gen/build.hxml $prj/build.hxml
			cp -rf ./gen/package.json $prj/distrib/package.json
			cp -rf ./gen/README.md $prj/distrib/README.md
		fi 
		
		rm -rf $prj/distrib/api.js

		cross-env mode=$mode cross-env prj=$prj ./gen/build.sh
		
		fi
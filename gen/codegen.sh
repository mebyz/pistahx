if [ -z "$prj" ]; then echo "project folder is unset, see README.md file"; else
java -jar ./gen/swagger-codegen-cli.jar generate \
-i $prj/app/api.yaml \
-l haxe-nodejs \
-t ./gen/haxe_mustache_templates \
-o $prj/distrib
fi


var gulp = require('gulp');
var shell = require('gulp-shell');
var gutil = require('gulp-util');
var prompt = require('gulp-prompt');

gulp.task('build', function(done) {

    process.env.VERT="\\033[1;32m";
    process.env.NORMAL="\\033[0;39m";
    process.env.ROUGE="\\033[1;31m";
    process.env.WDIR="./";

    var tasks = ['echo "$VERT" "#PISTAHX: running in mode:$mode" "$NORMAL"'];

	tasks.push('if [ -z "$root" ]; then echo "project root folder is unset, see README.md file"; else \n'+
		
		'if [ "$mode" = "build" ] ; then \n'+
			'echo "$VERT" "#PISTAHX: installing nodejs dependencies" "$NORMAL"\n'+
			'npm install\n'+
			'echo "$VERT" "#PISTAHX: updating nodejs dependencies" "$NORMAL"\n'+
			'npm update\n'+
			
                        'echo "$VERT" "#PISTAHX: setting OpenApi Doc UI folder" "$NORMAL"\n'+
			'mkdir -p ./doc\n'+
			'cp -rf ./node_modules/swagger-ui/dist/* ./doc/\n'+

			'echo "$VERT" "#PISTAHX: cleaning workspace" "$NORMAL"\n'+
			'rm -rf $prj/distrib/promhx\n'+
			'rm -rf $prj/distrib/haxe-js-kit\n'+
			'rm -rf $prj/distrib/api.js\n'+
			'mkdir -p $prj/distrib/\n'+
			'mkdir -p $prj/distrib/src/\n'+
			'echo "$VERT" "#PISTAHX: preparing distrib folder" "$NORMAL"\n'+
		'fi\n'+
		
		'echo "$VERT" "#PISTAHX: refresh Main.hx file" "$NORMAL"\n'+
		'cp -rf ./gen/Main.hx $prj/distrib/src/Main.hx\n'+
		'\n'+
		
		'if [ "$mode" = "build" ] ; then \n'+
			'cp -rf ./gen/build.hxml $prj/build.hxml\n'+
			'cp -rf ./gen/package.json $prj/distrib/package.json\n'+
			'cp -rf ./gen/README.md $prj/distrib/README.md\n'+
		'fi \n'+
		
		'rm -rf $prj/distrib/api.js\n'+

		'mode=$mode prj=$prj ./gen/build.sh\n'+
		
		'fi');


    return gulp.src('gulpfile.js')
                .pipe(shell(tasks));

});

gulp.task('run', function(done) {


});

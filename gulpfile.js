
var gulp = require('gulp');
var shell = require('gulp-shell');
var gutil = require('gulp-util');
var prompt = require('gulp-prompt');
var colors = require('colors');

gulp.task('build', function(done) {

    process.env.VERT="\\033[1;32m";
    process.env.NORMAL="\\033[0;39m";
    process.env.ROUGE="\\033[1;31m";
    process.env.WDIR="./";

    //var tasks = ['echo "$VERT" "#PISTAHX: running in mode:$mode" "$NORMAL"'];
    //
    var tasks = [];
    console.log('#PISTAHX: running in mode:$mode'.green);
    tasks.push('cross-env root=$root sh ./prepare.sh');


    return gulp.src('gulpfile.js')
                .pipe(shell(tasks));

});

gulp.task('run', function(done) {


});

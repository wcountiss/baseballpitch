var browserify = require('gulp-browserify'),
    uglify = require('gulp-uglify'),
    source = require('vinyl-source-stream'),
    buffer = require('vinyl-buffer'),
    gulp = require('gulp'),
    less = require('gulp-less'),
    minifycss = require('gulp-minify-css'),
    rename = require('gulp-rename'),
    clean = require('gulp-clean'),
    postcss = require('gulp-postcss'),
    autoprefixer = require('autoprefixer'),
    gls = require('gulp-live-server'),
    os = require('os'),
    open = require('gulp-open');
    wait = require('gulp-wait');
    

gulp.task('server', function () {
    var server = gls('server.coffee', undefined, 35729);
    server.start('node_modules/coffee-script/bin/coffee');
     gulp.watch(['public/**/*.less', 'public/**/*.html'], function (file) {
      server.notify.apply(server, [file]);
    });
    gulp.watch(['public/*.html'], server.notify());
    gulp.watch(['public/views/*.html'], server.notify());
    gulp.watch(['public/css/*.css'], server.notify());
    gulp.watch(['public/js/*.js'], server.notify());
    gulp.watch(['public/less/*.less'], server.notify());
    gulp.watch(['server.coffee'], [server.run]);
});

gulp.task('prod-server', function () {
    var server = gls('server.coffee', undefined);
    server.start('node_modules/coffee-script/bin/coffee');
});


gulp.task('clean', function () {  
  gulp.src('public/build/css', {read: false}).pipe(clean());
  gulp.src('public/build/js', {read: false}).pipe(clean());
});    

gulp.task('scripts', function() {

  gulp.src('./public/scripts/app.coffee', { read: false})
  .pipe(browserify({
    transform: ['coffeeify'],
    extensions: ['.coffee'],
  }))
  .pipe(buffer()) // <----- convert from streaming to buffered vinyl file object
  .pipe(uglify()) // now gulp-uglify works 
  .pipe(rename('app.js'))
  .pipe(gulp.dest('public/build/js'))
})

gulp.task('less', function(){

    gulp.src("public/less/app.less")
    .pipe(less({
      paths: [
        "public/less",
        "bower_components"
      ]
    }))
    .pipe(minifycss())
    .pipe(gulp.dest("public/build/css"))
})

gulp.task('watch', ['clean'], function () {
  gulp.watch('public/scripts/**', ['scripts']);
  gulp.watch('public/less/**', ['less']);
});

gulp.task('url', function(){
  gulp.src(__filename)
  .pipe(wait(1500))
  .pipe(open({uri: 'http://localhost:1979'}));
});


gulp.task('production', ['prod-server', 'clean', 'less', 'scripts'], function() {});
gulp.task('development', ['server','clean', 'less', 'scripts', 'watch', 'url'], function() {});


gulp.task('default', [process.env["NODE_ENV"] || 'development']);


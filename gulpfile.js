var browserify = require('gulp-browserify'),
    gulp = require('gulp'),
    uglify = require('gulp-uglify'),
    prefix = require('gulp-autoprefixer'),
    less = require('gulp-less'),
    minifycss = require('gulp-minify-css'),
    rename = require('gulp-rename'),
    clean = require('gulp-clean'),
    os = require('os'),
    injectReload = require('gulp-inject-reload'),
    gls = require('gulp-live-server'),
    open = require('gulp-open'),
    wait = require('gulp-wait');
    
gulp.task('server', function () {
  var options = {env: process.env};
  options.env.PARSE_APP_ID= process.env.PARSE_APP_ID || '7GO2ljMX3ZAogcE2hnEjggwRDnFPrs2uVtDDEaBM',
  options.env.PARSE_JS_KEY=process.env.PARSE_JS_KEY || 'OcWFRuUQxR8Oq5kR48tUjPQ1jk81v9RBGMy2f9AR',
  options.env.JWT_PASS=process.env.JWT_PASS || 'shhhhh',
  options.env.COOKIE_PASS=process.env.COOKIE_PASS || 'shhhhhhhhhh'
  var server = gls('server.coffee', options, 35729);
  server.start('node_modules/coffee-script/bin/coffee');
  gulp.watch(['public/**/*.html', 'public/**/**.css', 'public/**/**.js'], function (file) {
    //live reload the clientside files
    server.notify.apply(server, [file]);
  });
  gulp.watch(['lib/**/**.coffee', 'server.coffee', 'routes.coffee'], function (file) {
    // restart the server if changing serverside code
    server.stop();
    server.start();
  });
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
    .pipe(prefix({ cascade: true }))
    .pipe(minifycss())
    .pipe(gulp.dest("public/build/css"))
})

gulp.task('pages', function(){
    return gulp.src('public/views/index.html')
      .pipe(injectReload())
      .pipe(gulp.dest('public/build/views'))
});

gulp.task('watch', ['clean'], function () {
  gulp.watch('public/scripts/**', ['scripts']);
  gulp.watch('public/less/**', ['less']);
  gulp.watch('public/views/index.html', ['pages']);
});

gulp.task('url', function(){
  gulp.src(__filename)
  .pipe(wait(1500))
  .pipe(open({uri: 'http://localhost:2001'}));
});


gulp.task('production', ['less', 'scripts'], function() {});
gulp.task('development', ['clean', 'less', 'scripts', 'pages', 'watch', 'server', 'url'], function() {});


gulp.task('default', [process.env["NODE_ENV"] || 'development']);


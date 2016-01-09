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
    livereload = require('gulp-livereload'),
    nodemon = require('gulp-nodemon'),
    // notify = require('gulp-notify')
    open = require('gulp-open'),
    wait = require('gulp-wait');
    
gulp.task('server', function () {
  var options = {env: process.env};
  options.env.PARSE_APP_ID= process.env.PARSE_APP_ID || 'ALJhzeUWvXCauUXacwFjEIsjghkx1ZnZoCV0dhye',
  options.env.PARSE_JS_KEY=process.env.PARSE_JS_KEY || 'pCl0dZbm1RtPBXaG0hHnzWH1mjHCiSFP1u5akmw7',
  options.env.JWT_PASS=process.env.JWT_PASS || 'shhhhh',
  options.env.COOKIE_PASS=process.env.COOKIE_PASS || 'shhhhhhhhhh'
  options.env.BLUEBIRD_W_FORGOTTEN_RETURN=0
  nodemon({
    script: 'server.coffee',
    watch: ['lib', 'server.coffee', 'routes.coffee'],
    env: options.env
  })
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
  .pipe(livereload())
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
    .pipe(livereload())
})

gulp.task('pages', function(){
    gulp.src('public/**/*.html')
      .pipe(livereload())

    gulp.src('public/views/index.html')
      .pipe(injectReload())
      .pipe(gulp.dest('public/build/views'))
      .pipe(livereload())
});

gulp.task('watch', ['clean'], function () {
  gulp.watch('public/scripts/**', ['scripts']);
  gulp.watch('public/less/**', ['less']);
  gulp.watch('public/views/**', ['pages']);
  livereload.listen()
});

gulp.task('url', function(){
  gulp.src(__filename)
  .pipe(wait(3000))
  .pipe(open({uri: 'http://localhost:2001'}));
});


gulp.task('production', ['less', 'scripts'], function() {});
gulp.task('development', ['server', 'clean', 'less', 'scripts', 'pages', 'watch',  'url'], function() {});


gulp.task('default', [process.env["NODE_ENV"] || 'development']);


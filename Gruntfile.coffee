module.exports = (grunt) ->

  # load grunt modules
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    concat:
      css:
        src: [
          'app/css/main.css'
        ]
        dest: 'app/bundle.css'
    copy:
      main:
        files: [
           {expand: true, cwd: 'app/', src: ['*.html'], dest: 'dist/'}
           {expand: true, cwd: 'app/', src: ['pym.min.js'], dest: 'dist/'}
        ]
    cssmin:
      deploy:
        files:
          'dist/bundle.css': ['app/bundle.css']
    uglify:
      deploy:
        files:
          'dist/timeplot.js': ['app/timeplot.js']
          'dist/barplot.js': ['app/barplot.js']
    'gh-pages':
      options:
        base: 'dist'
      src: ['**']
    browserify:
      dist:
        files:
          'app/timeplot.js' : ['app/src/timeplot.coffee']
          'app/barplot.js' : ['app/src/barplot.coffee']
        options:
          transform: ['coffeeify']
    watch:
      coffee :
        files: [
          'app/src/*.coffee'
        ]
        tasks: ['browserify']
      css:
        files: ["app/css/*.css"]
        tasks: ["concat:css"]
    browserSync:
      bsFiles:
        src : [
          'app/src/*.coffee'
          'app/css/*.css'
          'app/index.html'
        ]
      options:
        watchTask: true
        server:
          baseDir: "app/"

  watch = [
    'browserSync'
    'watch'
  ]

  prep = [
    'browserify'
    'concat:css'
  ]

  deploy = [
    'copy:main'
    'uglify:deploy'
    'cssmin:deploy'
    'gh-pages'
  ]

  # Coffee compiling, uglifying and watching in order
  grunt.registerTask 'default', prep.concat(watch)
  grunt.registerTask 'deploy', prep.concat(deploy)


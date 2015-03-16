module.exports = (grunt) ->

  # load grunt modules
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    concat:
      css:
        src: ['app/css/*.css']
        dest: 'app/bundle.css'
    copy:
      main:
        files: [
           {expand: true, cwd: 'app/', src: ['index.html'], dest: 'dist/'}
        ]
    cssmin:
      deploy:
        files:
          'dist/bundle.css': ['app/bundle.css']
    uglify:
      deploy:
        files:
          'dist/bundle.js': ['app/bundle.js']
    'gh-pages':
      options:
        base: 'dist'
      src: ['**']
    browserify:
      dist:
        files:
          'app/bundle.js' : ['app/src/main.coffee']
        options:
          transform: ['coffeeify']
    watch:
      coffee :
        files: [
          'app/src/*.coffee'
          'app/src/interactive/*.coffee'
          'app/src/modeler/*.coffee'
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


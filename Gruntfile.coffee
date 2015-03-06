module.exports = (grunt) ->

  # load grunt modules
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    concat:
      css:
        src: ['app/css/*.css']
        dest: 'app/bundle.css'
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

  # Coffee compiling, uglifying and watching in order
  grunt.registerTask 'default', prep.concat(watch)

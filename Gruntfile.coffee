module.exports = (grunt) ->
  grunt.initConfig
    browserify: 
      dist: 
        files: 
          'lib/main.js' : ['src/*.coffee']
        options:  
          transform: ['coffeeify']
          browserifyOptions:
            standalone: 'LogmeInClientAuth'
    meta:
      src: 'lib/main.js'
      specs: 'build/tests.js'

    watch:
        files: '**/*.coffee'
        tasks: ['test']

    jasmine:
      src: '<%= meta.src %>'
      options:
        specs: '<%= meta.specs %>'
        vendor: [
          'bower_components/http/http.js' 
          'bower_components/jasmine-given/dist/jasmine-given.js'
          'bower_components/sinon/lib/sinon.js'
        ]
    coffee:
      compile:
        files:
          'build/tests.js': ['test/*.coffee']

    docco: 
      debug:
        src: ['src/**/*.coffee']
        options: 
          output: 'docs/'
          layout: 'linear'

   
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-docco'

 
  grunt.registerTask 'default', ['browserify', 'coffee', 'jasmine', 'docco']
  grunt.registerTask 'test', ['browserify', 'coffee', 'jasmine']
  grunt.registerTask 'doc', ['docco']
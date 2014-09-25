module.exports = (grunt) ->
  grunt.initConfig
    mochaTest:
      options:
        reporter: 'list'
      src: ['test/*.coffee']
    browserify: 
      dist: 
        files: 
          'lib/auth.js' : ['src/*.coffee']
        options: 
          transform: ['coffeeify']
   

  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-browserify'

  grunt.registerTask 'default', ['browserify', 'mochaTest']
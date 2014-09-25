module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'lib/auth.js': ['src/*.coffee']
    mochaTest:
      options:
        reporter: 'list'
      src: ['test/*.coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.registerTask 'default', ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', ['coffee', 'mochaTest']
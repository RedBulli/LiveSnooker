module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    coffee:
      config:
        options:
          bare: true
        files: [
          {
            expand: true
            cwd: 'coffees'
            src: ['**/*.coffee']
            dest: 'build'
            ext: '.js'
          }
        ]

    clean:
      js:
        src: ['build/**/*.js']

    watch:
      coffee:
        files: 'coffees/**/*.coffee'
        tasks: ['clean', 'coffee', 'karma:unit:run']

    connect:
      server:
        options:
          port: 9000
          base: "./public"

    karma:
      unit:
        configFile: 'karma.conf.js'
        singleRun: false
        background: true

  grunt.registerTask 'serve', ['concurrent:serve']

  grunt.registerTask 'default', ['karma:unit', 'clean', 'coffee', 'connect:server', 'watch']

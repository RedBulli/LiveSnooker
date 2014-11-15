module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    env:
      dev:
        BACKEND_HOST: 'http://localhost:5000'
      dist:
        src: '.env'
        BACKEND_HOST: 'https://livesnooker-server.herokuapp.com'

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
          base: "./build"

    karma:
      unit:
        configFile: 'karma.conf.js'
        singleRun: false
        background: true

    preprocess:
      html:
        src: 'index.html',
        dest : 'build/index.html'

    concurrent:
      serve: ['connect:server']

    copy:
      dist:
        files: [
          {expand: true, cwd: 'elements', src: ['**'], dest: 'build/elements'},
        ]

  grunt.registerTask 'serve', ['build', 'connect:server', 'watch']

  grunt.registerTask 'build', [
    'preprocess:html', 'copy:dist'
  ]

  grunt.registerTask 'dist', [
    'env:dist', 'preprocess:html', 'copy:dist'
  ]

  grunt.registerTask 'default', [
    'env:dev', 'karma:unit', 'build', 'connect:server', 'watch'
  ]

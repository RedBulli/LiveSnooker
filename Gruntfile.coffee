module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    env:
      options:
        add: # Default env values
          BACKEND_HOST: 'http://localhost:5000'
      build:
        src: '.env'

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

    preprocess:
      html:
        src: 'index.html',
        dest : 'public/index.html'

  grunt.registerTask 'serve', ['concurrent:serve']

  grunt.registerTask 'build', [
    'env:build', 'preprocess:html', 'clean', 'coffee'
  ] 

  grunt.registerTask 'default', [
    'karma:unit', 'build', 'connect:server', 'watch'
  ]

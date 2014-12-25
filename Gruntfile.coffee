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
      app: 
        files: [{
          expand: true
          cwd: 'elements'
          src: ['**/*.coffee']
          dest: 'build/elements'
          ext: '.js'
        }]
      specs:
        files: [{
          expand: true
          cwd: 'specs'
          src: ['**/*.coffee']
          dest: 'specs_build'
          ext: '.js'
        }]

    clean:
      elements:
        src: ['build/elements/**/*']
      elements_html:
        src: ['build/elements/**/*.html']
      elements_js:
        src: ['build/elements/**/*.js']
      specs:
        src: ['specs_build/**/*.js']

    watch:
      coffee:
        files: ['elements/**/*.coffee', 'specs/**/*.coffee']
        tasks: ['clean:elements_js', 'coffee', 'karma:unit:run']
      public_html:
        files: ['public/*.html']
        tasks: ['preprocess:html', 'karma:unit:run']
      elements_html:
        files: ['elements/**/*.html']
        tasks: ['clean:elements_html', 'copy:html', 'karma:unit:run']

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
      ci:
        configFile: 'karma.conf.js'
        singleRun: true

    preprocess:
      html:
        src: 'public/index.html'
        dest : 'build/index.html'

    concurrent:
      serve: ['connect:server']
      options:
        livereload: true

    copy:
      html:
        files: [
          {expand: true, cwd: 'elements', src: ['**/*'], dest: 'build/elements'},
        ]

  grunt.registerTask 'serve', ['build:dev', 'connect:server', 'watch']

  grunt.registerTask 'build', (target) ->
    if target == 'dist'
      grunt.task.run(['env:dist'])
    else if target == 'dev'
      grunt.task.run(['env:dev'])
    else if target == 'test'
      grunt.task.run(['env:dev', 'clean:specs', 'coffee:specs'])
    grunt.task.run(['clean:elements', 'preprocess:html', 'coffee:app', 'copy:html'])

  grunt.registerTask 'default', [
    'karma:unit', 'serve'
  ]

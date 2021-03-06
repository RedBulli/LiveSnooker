module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    env:
      dev:
        src: 'environments/development.env'
      dist:
        src: 'environments/dist.env'

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
        src: ['specs_build/**/*']

    watch:
      coffee:
        files: ['elements/**/*.coffee', 'specs/**/*.coffee']
        tasks: ['clean:elements_js', 'copy', 'clean:specs', 'coffee']
      public_html:
        files: ['public/*.html']
        tasks: ['preprocess:html', ]
      elements_html:
        files: ['elements/**/*.html']
        tasks: ['clean:elements_html', 'copy']

    connect:
      server:
        options:
          port: process.env.PORT || 9000
          base: "./build"
          middleware: (connect, options, middlewares) ->
            middlewares.unshift (req, res, next) ->
              res.setHeader('Access-Control-Allow-Origin', '*')
              res.setHeader('Access-Control-Allow-Methods', '*')
              next()
            middlewares

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
        files: {
          'build/index.html': 'public/index.html',
          'build/frame.html': 'public/frame.html'
        }

    concurrent:
      serve: ['connect:server']
      options:
        livereload: true

    copy:
      html:
        files: [
          {expand: true, cwd: 'elements', src: ['**/*'], dest: 'build/elements'},
        ]
      vendors:
        files : [
          expand: false,
          cwd: 'build/vendors',
          dest: 'build/elements/js/vendor',
          src: [
            'build/vendors/jquery/jquery.js',
            'build/vendors/underscore/underscore.js',
            'build/vendors/backbone/backbone.js',
            'build/vendors/backbone-relational/backbone-relational.js'
          ]
        ]

    vulcanize:
      index:
        options:
          abspath: 'build/'
          inlineScripts: true
          inlineCss: true
          stripComments: true
          csp: "index-csp.js"
          targetUrl: 'index.html'
        files:
          "build/index.html": "build/index.html"
      frame:
        options:
          abspath: 'build/'
          inlineScripts: true
          inlineCss: true
          stripComments: true
          csp: "frame-csp.js"
          targetUrl: 'frame.html'
        files:
          "build/frame.html": "build/frame.html"

  grunt.registerTask 'serve', ['build:dev', 'connect:server', 'watch']

  grunt.registerTask 'build', (target) ->
    if target == 'dist'
      grunt.task.run(['env:dist'])
    else if target == 'dev' || target == 'dev-vulcanize'
      grunt.task.run(['env:dev'])
    else if target == 'test'
      grunt.task.run(['env:dev', 'clean:specs', 'coffee:specs'])
    grunt.task.run(['clean:elements', 'preprocess:html', 'coffee:app', 'copy:html'])
    if target == 'dist' || target == 'dev-vulcanize'
      grunt.task.run(['vulcanize'])

  grunt.registerTask 'default', [
    'serve'
  ]

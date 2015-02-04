module.exports = function(config) {
  cfg = {
    files: [
      "build/vendors/webcomponentsjs/webcomponents.js",
      {pattern: 'build/vendors/**', included: false, served: true},
      {pattern: 'build/elements/**', included: false, served: true},
      'specs_build/helper.js',
      'specs_build/fixtures.js',
      'specs_build/**/*_spec.js'
    ],
    plugins: [
      'karma-mocha',
      'karma-chrome-launcher',
      'karma-growl-reporter',
      'karma-sinon-chai'
    ],
    frameworks: ['mocha', 'sinon-chai'],
    client: {
      mocha: {
        reporter: 'html', // change Karma's debug.html to the mocha web reporter
        ui: 'tdd',
        require: ['specs_build/helper.js']
      }
    },
    browsers: [
      'Chrome',
    ],
    customLaunchers: {
      Chrome_travis_ci: {
        base: 'Chrome',
        flags: ['--no-sandbox']
      }
    },
    singleRun: false,
    autoWatch: false,
    reporters: ['progress', 'growl'],
    port: 9876,
    logLevel: config.LOG_INFO
  };

  if (process.env.TRAVIS) {
    cfg.browsers = ['Chrome_travis_ci'];
  }

  config.set(cfg);
};

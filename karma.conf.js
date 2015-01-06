module.exports = function(config) {
  //var common = require('./build/vendors/polymer-test-tools/karma-common.conf.js');

  config.set({
    files: [
      "build/vendors/webcomponentsjs/webcomponents.js",
      {pattern: 'build/vendors/**', included: false, served: true},
      {pattern: 'build/elements/**', included: false, served: true},
      'specs_build/helper.js',
      'specs_build/**/*_spec.js'
    ],
    plugins: [
      'karma-mocha',
      'karma-script-launcher',
      'karma-chrome-launcher',
      'karma-firefox-launcher',
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
      //'Firefox'
    ],
    singleRun: false,
    autoWatch: false,
    reporters: ['progress', 'growl'],
    port: 9876,
    logLevel: config.LOG_INFO
  });
};

module.exports = function(config) {
  //var common = require('./build/vendors/polymer-test-tools/karma-common.conf.js');

  config.set({
    files: [
      "build/vendors/webcomponentsjs/webcomponents.js",
      {pattern: 'build/vendors/**', included: false, served: true},
      {pattern: 'build/elements/**', included: false, served: true},
      'specs_build/**/*_spec.js'
    ],
    plugins: [
      'karma-mocha',
      'karma-script-launcher',
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      'karma-chai',
      'karma-growl-reporter'
    ],
    frameworks: ['mocha', 'chai'],
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

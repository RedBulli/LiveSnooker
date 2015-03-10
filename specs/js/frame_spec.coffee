describe 'Frame', ->
  before (done) ->
    mocha.globals.importElement("/base/build/elements/js/frame.html", done)

  before (done) ->
    mocha.globals.importElement("/base/build/elements/js/players.html", done)

  it 'imports', ->
    frame = mocha.globals.fixtures.frame()

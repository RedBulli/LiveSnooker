createEvent = ->
  target:
    getAttribute: ->
      2

describe 'Frame-Input', ->
  element = null
  before (done) ->
    mocha.globals.importElement("/base/build/elements/input/frame-input.html", done)

  beforeEach ->
    element = document.createElement('frame-input')
    element.model =
      addShot: sinon.spy()
      createShot: sinon.spy()
    document.body.appendChild(element)

  afterEach ->
    document.body.removeChild(element)
    
  it 'adds shots to the frame when points-input triggers onShot', ->
    pointsInput = element.shadowRoot.getElementsByTagName('points-input')[0]
    pointsInput.onShot(createEvent())
    expect(element.model.createShot).to.have.been.called

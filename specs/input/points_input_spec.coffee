describe 'Points-Input', ->
  element = null
  before (done) ->
    mocha.globals.importElement("/base/build/elements/input/points-input.html", done)

  beforeEach ->
    element = document.createElement('points-input')
    document.body.appendChild(element)

  afterEach ->
    document.body.removeChild(element)
    
  it 'triggers fire when a ball is clicked', ->
    sinon.spy(element, "fire")
    ball = element.shadowRoot.getElementsByTagName('snooker-ball')[3]
    ball.click()
    expect(element.fire).to.have.been.called

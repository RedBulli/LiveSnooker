describe 'FrameController', ->
  element = null
  before (done) ->
    link = document.createElement("link")
    link.rel = "import"
    link.href = "/base/build/elements/live-snooker-input/live-snooker-input.html"
    link.onload = -> done()
    document.getElementsByTagName("head")[0].appendChild(link)

  beforeEach (done) ->
    element = document.createElement('live-snooker-input')
    element.action_url = 'http://livesnooker-server.herokuapp.com'
    rea = ->
      done()
    document.body.appendChild(element)
    setTimeout(rea, 0)

  afterEach ->
    document.body.removeChild(element)

  it 'works', ->
    expect(element.shadowRoot.querySelector('#frameForm').getAttribute('action')).to.equal 'http://livesnooker-server.herokuapp.com'
    
  it 'works', ->
    expect(element.shadowRoot.querySelector('#frameForm').getAttribute('action')).to.equal 'http://livesnooker-server.herokuapp.com'

  it 'works', ->
    expect(element.shadowRoot.querySelector('#frameForm').getAttribute('action')).to.equal 'http://livesnooker-server.herokuapp.com'

  it 'works', ->
    expect(element.shadowRoot.querySelector('#frameForm').getAttribute('action')).to.equal 'http://livesnooker-server.herokuapp.com'

  it 'works', ->
    expect(element.shadowRoot.querySelector('#frameForm').getAttribute('action')).to.equal 'http://livesnooker-server.herokuapp.com'

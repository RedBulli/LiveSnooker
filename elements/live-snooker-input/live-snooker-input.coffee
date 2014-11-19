$.fn.serializeObject = ->
  o = {}
  a = this.serializeArray()
  $.each a, ->
    if o[this.name] != undefined
      if !o[this.name].push
        o[this.name] = [o[this.name]]
      o[this.name].push(this.value || '')
    else
      o[this.name] = this.value || ''
  o

listenForChanges = ->
  console.log("listening")
  _this = this

  $(_this.$.frameForm).find('input').change (event) ->
    $.ajax
      type: "POST"
      url: $(_this.$.frameForm).attr('action')
      data: JSON.stringify($(_this.$.frameForm).serializeObject())
      headers:
        "Content-Type": "application/json"

Polymer
  domReady: listenForChanges
  ready: ->
    @action_url = @action_url || ""

  # action_urlChanged: (val) ->
  #   @$.frameForm.setAttribute('action', @action_url)

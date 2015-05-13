sequences = {}
sequence = (name) ->
  current = sequences[name] || 0
  sequences[name] = current + 1

mocha.globals.fixtures =
  player: ->
    id = sequence('player')
    new Player(id: id, name: "sampo_#{id}")

  framePlayers: ->
    new Players([@player(), @player()])

  frame: ->
    new Frame(
      id: sequence('frame'),
      Players: @framePlayers()
    )

angular.module('motus').factory 'currentPlayerFactory', [ '$player', '$q', ($player, $q)  ->
  cpf = this

  cpf.getCurrentPlayer = () ->
    if cpf.currentPlayer
      return $q.when(cpf.currentPlayer)
    else
      $player.getPlayers()
      .then (players) ->
        cpf.currentPlayer = players[0]

  # return the factory object
  cpf
]

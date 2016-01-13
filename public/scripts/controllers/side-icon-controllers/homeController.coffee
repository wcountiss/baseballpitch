angular.module('motus').controller 'homeController', ['currentPlayerFactory','eliteFactory','$state',(currentPlayerFactory, eliteFactory, $state) ->
  home = this
  home.state = $state
  cpf = currentPlayerFactory
  ef = eliteFactory
  cpf.getCurrentPlayer().then () ->
    home.currentPlayer = cpf.currentPlayer
    console.log 'home.currentPlayer: ',home.currentPlayer
  ef.getEliteMetrics()


  return home
]

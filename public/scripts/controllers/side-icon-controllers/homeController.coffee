angular.module('motus').controller 'homeController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  home = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  cpf.getCurrentPlayer().then () ->
    home.currentPlayer = cpf.currentPlayer
    console.log 'home.currentPlayer: ',home.currentPlayer
  ef.getEliteMetrics()


  return home
]

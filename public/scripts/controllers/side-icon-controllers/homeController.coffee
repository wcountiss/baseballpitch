angular.module('motus').controller 'homeController', ['currentPlayerFactory','eliteFactory','$state',(currentPlayerFactory, eliteFactory, $state) ->
  home = this
  home.state = $state
  cpf = currentPlayerFactory
  ef = eliteFactory
  cpf.getCurrentPlayer().then () ->
    home.currentPlayer = cpf.currentPlayer
  ef.getEliteMetrics()


  return home
]

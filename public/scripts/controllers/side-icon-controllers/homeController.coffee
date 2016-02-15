angular.module('motus').controller 'homeController', ['currentPlayerFactory','eliteFactory','$state','$locHistory',(currentPlayerFactory, eliteFactory, $state, $locHistory) ->
  home = this
  home.state = $state
  cpf = currentPlayerFactory
  ef = eliteFactory
  $locHistory.lastLocation()
  cpf.getCurrentPlayer().then () ->
    home.currentPlayer = cpf.currentPlayer
  ef.getEliteMetrics()


  return home
]

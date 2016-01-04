angular.module('motus').controller 'homeController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  home = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  home.greeting = 'hello from snapShotController'
  home.currentPlayer = cpf.currentPlayer
  console.log 'home.currentPlayer: ',home.currentPlayer
]

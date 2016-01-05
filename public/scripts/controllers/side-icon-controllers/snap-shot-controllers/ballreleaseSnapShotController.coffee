angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  ballrelease = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ef.getEliteMetrics()

  ballrelease.greeting = 'hello from footcontactSnapShotController'
  ballrelease.currentPlayer = cpf.currentPlayer
  console.log 'ballrelease.currentPlayer: ',ballrelease.currentPlayer
]

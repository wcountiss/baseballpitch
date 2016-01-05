angular.module('motus').controller 'trendsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  trends = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ef.getEliteMetrics()
  trends.greeting = 'hello from trendsController'
  trends.currentPlayer = cpf.currentPlayer
  console.log 'trends.currentPlayer: ',trends.currentPlayer
]

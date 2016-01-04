angular.module('motus').controller 'trendsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  trends = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  trends.greeting = 'hello from trendsController'
  trends.currentPlayer = cpf.currentPlayer
]

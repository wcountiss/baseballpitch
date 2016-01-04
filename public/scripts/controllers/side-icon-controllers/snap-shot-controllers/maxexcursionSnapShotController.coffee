angular.module('motus').controller 'maxexcursionSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  max = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  max.greeting = 'hello from maxexcursionSnapShotController'
  max.currentPlayer = cpf.currentPlayer
  console.log 'max.currentPlayer: ',max.currentPlayer
]

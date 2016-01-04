angular.module('motus').controller 'maxexcursionSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  me = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  me.greeting = 'hello from maxexcursionSnapShotController'
  me.currentPlayer = cpf.currentPlayer
]

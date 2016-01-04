angular.module('motus').controller 'snapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  sc = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  sc.greeting = 'hello from snapShotController'
  sc.currentPlayer = cpf.currentPlayer
]

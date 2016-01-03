angular.module('motus').controller 'snapShotController', ['currentPlayerFactory', (currentPlayerFactory) ->
  sc = this
  cpf = currentPlayerFactory
  sc.greeting = 'hello from snapShotController'
  sc.currentPlayer = cpf.currentPlayer
  return
]

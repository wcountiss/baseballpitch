angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  footcontact = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  footcontact.greeting = 'hello from footcontactSnapShotController'
  footcontact.currentPlayer = cpf.currentPlayer
]

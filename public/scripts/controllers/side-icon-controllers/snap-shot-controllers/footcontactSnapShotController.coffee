angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  footcontact = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ef.getEliteMetrics()

  footcontact.greeting = 'hello from footcontactSnapShotController'
  footcontact.currentPlayer = cpf.currentPlayer
  console.log 'footcontact.currentPlayer: ',footcontact.currentPlayer
]

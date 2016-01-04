angular.module('motus').controller 'kineticsSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  kinetics = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  kinetics.greeting = 'hello from kineticsSnapShotController'
  kinetics.currentPlayer = cpf.currentPlayer
]

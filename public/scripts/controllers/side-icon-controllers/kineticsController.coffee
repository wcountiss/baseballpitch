angular.module('motus').controller 'kineticsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  kinetics = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  kinetics.greeting = 'hello from kineticsController'
  kinetics.currentPlayer = cpf.currentPlayer
  console.log 'kinetics.currentPlayer: ',kinetics.currentPlayer
]

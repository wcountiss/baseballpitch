angular.module('motus').controller 'jointKineticsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  joint = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  joint.greeting = 'hello from jointKineticsController'
  joint.currentPlayer = cpf.currentPlayer
]

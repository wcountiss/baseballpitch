angular.module('motus').controller 'kineticChainController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  joint = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  joint.greeting = 'hello from kineticChainController'
  joint.currentPlayer = cpf.currentPlayer
  console.log 'joint.currentPlayer: ',joint.currentPlayer
]

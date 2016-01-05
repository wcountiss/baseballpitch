angular.module('motus').controller 'kineticChainController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  chain = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  chain.greeting = 'hello from kineticChainController'
  chain.currentPlayer = cpf.currentPlayer
  console.log 'chain.currentPlayer: ',chain.currentPlayer

]

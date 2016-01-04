angular.module('motus').controller 'kineticsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  kinetics = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  kinetics.greeting = 'hello from kineticsController'
  kinetics.currentPlayer = cpf.currentPlayer
  console.log 'kinetics.currentPlayer: ',kinetics.currentPlayer
  newObj = ef.eliteKinetics
  newObj = _.each (newObj), (addon) ->
    addon = _.extend(addon, {value: _.random(99)})
    addon
  kinetics.eliteMetrics = newObj
  console.log kinetics.eliteMetrics
]

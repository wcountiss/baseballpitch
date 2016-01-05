angular.module('motus').controller 'jointKineticsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  # self reference
  joint = this
  # grab factory data
  cpf = currentPlayerFactory
  ef = eliteFactory
  # controller logic
  joint.greeting = 'hello from jointKineticsController'
  joint.currentPlayer = cpf.currentPlayer
  console.log 'joint.currentPlayer: ',joint.currentPlayer
  newObj = ef.eliteKinetics
  newObj = _.each (newObj), (addon) ->
    addon = _.extend(addon, {value: _.random(99)})
    addon
  joint.eliteMetrics = newObj
  console.log joint.eliteMetrics
]

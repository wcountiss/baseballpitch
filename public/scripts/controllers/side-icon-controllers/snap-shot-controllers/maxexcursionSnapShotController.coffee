angular.module('motus').controller 'maxexcursionSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  max = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ef.getEliteMetrics().then (data) ->
    newObj = ef.eliteMaxexcursion
    newObj = _.each (newObj), (addOn) ->
      addon = _.extend(addOn, {value: _.random(99)})
      addon
    max.eliteMetrics = newObj
    console.log max.eliteMetrics

  max.currentPlayer = cpf.currentPlayer
  console.log 'max.currentPlayer: ',max.currentPlayer
]

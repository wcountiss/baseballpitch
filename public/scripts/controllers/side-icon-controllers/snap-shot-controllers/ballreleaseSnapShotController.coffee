angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  ball = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ef.getEliteMetrics().then (data) ->
    newObj = ef.eliteBallrelease
    newObj = _.each (newObj), (addOn) ->
      addon = _.extend(addOn, {value: _.random(99)})
      addon
    ball.eliteMetrics = newObj
    console.log 'ball.eliteMetrics: ',ball.eliteMetrics

  ball.currentPlayer = cpf.currentPlayer
  console.log 'ball.currentPlayer: ',ball.currentPlayer
]

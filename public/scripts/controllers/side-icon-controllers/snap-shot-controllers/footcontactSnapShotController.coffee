angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  foot = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ef.getEliteMetrics().then (data) ->
    newObj = ef.eliteFootcontact
    newObj = _.each (newObj), (addOn) ->
      addOn = _.extend(addOn, {value: _.random(99)})
      addOn
    foot.eliteMetrics = newObj
    console.log 'foot.eliteMetrics: ',foot.eliteMetrics

  foot.currentPlayer = cpf.currentPlayer
  console.log 'foot.currentPlayer: ',foot.currentPlayer
]

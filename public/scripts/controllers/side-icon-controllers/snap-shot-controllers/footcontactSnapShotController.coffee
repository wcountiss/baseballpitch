angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  foot = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  foot.setClickedRow = (index) ->
    foot.selectedRow = index
    console.log("value of index:",index)
    console.log("value of var:", foot.selectedRow)
    console.log("TRUE OR FALSE", foot.selectedRow == index)

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

angular.module('motus').controller 'maxexcursionSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  max = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  max.legend = [
    {
    metric : "maxElbowFlexion",
    title: "Max Elbow Flexion",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "maxShoulderRotation",
    title: "Max Shoulder Rotation",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "maxTrunkSeparation",
    title: "Max Trunk Separation",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "maxFootHeight",
    title: "Max Foot Height",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    }
  ]

  max.setClickedRow = (index) ->
    max.selectedRow = index
    

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

angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  ball = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ball.selectedRow = null

  ball.legend = [
    {
    metric : "fingerTipVelocityRelease",
    title: "Fingertip Velocity Release",
    imgurl: "",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "forearmSlotRelease",
    title: "Forearm Slot Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "elbowFlexionRelease",
    title: "Elbow Flexion Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "shoulderRotationRelease",
    title: "Shoulder Rotation Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "shoulderAbductionRelease",
    title: "Shoulder Abduction Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "trunkSideTiltRelease",
    title: "Trunk Side Tilt Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "trunkFlexionRelease",
    title: "Trunk Flexion Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "trunkRotationRelease",
    title: "Trunk Rotation Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "pelvisSideTiltRelease",
    title: "Pelvis Side Tilt Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "pelvisFlexionRelease",
    title: "Pelvis Flexion Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "pelvisRotationRelease",
    title: "Pelvis Rotation Release",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    }
  ]

  ball.setClickedRow = (index) ->
    ball.selectedRow = index
    console.log("value of index:",index)
    console.log("value of var:", ball.selectedRow)
    console.log("TRUE OR FALSE", ball.selectedRow == index)

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

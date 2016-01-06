angular.module('motus').controller 'jointKineticsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  # self reference
  joint = this
  # grab factory data
  cpf = currentPlayerFactory
  ef = eliteFactory
  joint.selectedRow = null

  joint.legend = [
    {
    metric : "peakElbowCompressiveForce",
    title: "Elbow Compressive Force",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "peakElbowValgusTorque",
    title: "Elbow Valgus Torque",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "peakShoulderRotationTorque",
    title: "Shoulder Rotation Torque",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "peakShoulderCompressiveForce",
    title: "Shoulder Compressive Force",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    },

    {
    metric : "peakShoulderAnteriorForce",
    title: "Shoulder Anterior Force",
    imgurl: "http://www.amazon.com",
    eliterange: "",
    description: "",
    unit: ""
    }
  ]
  
  joint.setClickedRow = (index) ->
    console.log("LEGEND:",joint.legend[index].title)
    joint.selectedRow = index

  ef.getEliteMetrics().then (metrics) ->
    # controller logic
    joint.greeting = 'hello from jointKineticsController'
    joint.currentPlayer = cpf.currentPlayer
    console.log 'joint.currentPlayer: ',joint.currentPlayer
    newObj = ef.eliteKinetics
    newObj = _.each (newObj), (addon) ->
      addon.value = _.random(99)
      newObj= addon
    joint.eliteMetrics = newObj
    console.log "ELITE FACTORY RETURNS:",joint.eliteMetrics


  joint
]

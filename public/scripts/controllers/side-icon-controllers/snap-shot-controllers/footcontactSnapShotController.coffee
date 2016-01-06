angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  foot = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  foot.selectedRow = null
  foot.image = "images/legend/FC_ElbowFlexion.jpg"

  foot.legend = [
    {
    metric : "elbowFlexionFootContact",
    title: "Elbow Flexion Foot Contact",
    imgurl: "images/legend/FC_ElbowFlexion.jpg",
    eliterange: "35-38",
    description: "This is some sample description text",
    unit: ""
    },

    {
    metric : "shoulderRotationFootContact",
    title: "Shoulder Rotation Foot Contact",
    imgurl: "images/legend/FC_ShoulderRotation.jpg",
    eliterange: "68-99",
    description: "This is alternative and different description text",
    unit: ""
    },

    {
    metric : "shoulderAbductionFootContact",
    title: "Shoulder Abduction Foot Contact",
    imgurl: "images/legend/FC_ShoulderAbduction.jpg",
    eliterange: "34-76",
    description: "This is how we'll describe this particular metric",
    unit: ""
    },

    {
    metric : "trunkSideTiltFootContact",
    title: "Trunk Side Tilt Foot Contact",
    imgurl: "images/legend/FC_Trunk-Side-Tilt.jpg",
    eliterange: "55-55",
    description: "We've taken some care to change this description text",
    unit: ""
    },

    {
    metric : "trunkFlexionFootContact",
    title: "Trunk Flexion Foot Contact",
    imgurl: "images/legend/FC_TrunkFlexion.jpg",
    eliterange: "60-63",
    description: "This is alltogether different text again very different",
    unit: ""
    },

    {
    metric : "trunkRotationFootContact",
    title: "Trunk Rotation Foot Contact",
    imgurl: "images/legend/FC_TrunkRotation.jpg",
    eliterange: "45-90",
    description: "Ok great more description text that should look a bit different than before",
    unit: ""
    },

    {
    metric : "pelvisSideTiltFootContact",
    title: "Pelvis Side Tilt Foot Contact",
    imgurl: "images/legend/FC_PelvisSideTilt.jpg",
    eliterange: "80-90",
    description: "This is some very very very different discriptive text",
    unit: ""
    },

    {
    metric : "pelvisFlexionFootContact",
    title: "Pelvis Flexion Foot Contact",
    imgurl: "images/legend/FC_PelvisFlexion.jpg",
    eliterange: "98-100",
    description: "It's getting pretty late and I think I'm tried descriptive text",
    unit: ""
    },

    {
    metric : "pelvisRotationFootContact",
    title: "Pelvis Rotation Foot Contact",
    imgurl: "images/legend/FC_PelvisRotation.jpg",
    eliterange: "74-90",
    description: "3AM descriptive text written with probably a whole bunch of spelling errors",
    unit: ""
    },

    {
    metric : "footAngle",
    title: "Foot Angle",
    imgurl: "images/legend/FC_FootAngle.jpg",
    eliterange: "60-100",
    description: "More descriptive text but shorter sentence",
    unit: ""
    },

    {
    metric : "strideLength",
    title: "Stride Length",
    imgurl: "images/legend/FC_StrideLength.jpg",
    eliterange: "20-60",
    description: "A very short descriptive text discussing a particular metric",
    unit: ""
    }
  ]

  foot.setClickedRow = (index) ->
    foot.selectedRow = index
    foot.image = foot.legend[index].imgurl
    foot.title = foot.legend[index].title
    foot.desc = foot.legend[index].description
    foot.range = foot.legend[index].eliterange
    
    

  ef.getEliteMetrics().then (data) ->
    newObj = foot.legend
    newObj = _.each (newObj), (addOn) ->
      addOn = _.extend(addOn, {value: _.random(99)})
      addOn
    foot.eliteMetrics = newObj
    console.log 'foot.eliteMetrics: ',foot.eliteMetrics

  foot.currentPlayer = cpf.currentPlayer
  console.log 'foot.currentPlayer: ',foot.currentPlayer
]

angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  foot = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  imageMap = {
    "elbowFlexionFootContact": "images/legend/FC_ElbowFlexion.jpg",
    "shoulderRotationFootContact": "images/legend/FC_ShoulderRotation.jpg",
    "shoulderAbductionFootContact": "images/legend/FC_ShoulderAbduction.jpg",
    "trunkSideTiltFootContact": "images/legend/FC_Trunk-Side-Tilt.jpg",
    "trunkFlexionFootContact": "images/legend/FC_TrunkFlexion.jpg",
    "trunkRotationFootContact": "images/legend/FC_TrunkRotation.jpg",
    "pelvisSideTiltFootContact": "images/legend/FC_PelvisSideTilt.jpg",
    "pelvisFlexionFootContact": "images/legend/FC_PelvisFlexion.jpg",
    "pelvisRotationFootContact": "images/legend/FC_PelvisRotation.jpg",
    "footAngle": "images/legend/FC_FootAngle.jpg",
    "strideLength": "images/legend/FC_StrideLength.jpg",
  }

  foot.setClickedRow = (eliteMetric) ->
    foot.selectedMetric = eliteMetric
    foot.image = imageMap[foot.selectedMetric.metric]
    foot.selectedPlayerMetric = foot.currentPlayer.stats.metricScores[foot.selectedMetric.metric].score

  ef.getEliteMetrics()
  .then () ->
    foot.currentPlayer = cpf.currentPlayer
    foot.eliteMetrics = ef.eliteFootcontact
    _.each foot.eliteMetrics, (eliteMetric) -> eliteMetric.rating = foot.currentPlayer.stats.metricScores[eliteMetric.metric].rating
    foot.setClickedRow(foot.eliteMetrics[0])
    console.log 'foot.eliteMetrics: ',foot.eliteMetrics

  console.log 'foot.currentPlayer: ',foot.currentPlayer
]

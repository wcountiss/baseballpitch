angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory', '$stat', '$q',(currentPlayerFactory, eliteFactory, $stat, $q) ->
  foot = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  foot.filterType = '30'

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

  foot.filterLastThrowType = () ->
    if foot.filterType == '30'
      _.each foot.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = foot.currentPlayer.stats.metricScores[eliteMetric.metric]
    else
      $stat.filterLastThrowType(foot.currentPlayer.pitches, foot.filterType)
      .then (stats) ->
        _.each foot.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]

  foot.setClickedRow = (eliteMetric,index) ->
    cpf.footMetricsIndex = index
    console.log 'cpf.footMetricsIndex:',cpf.footMetricsIndex
    foot.selectedMetric = eliteMetric
    console.log 'foot.selectedMetric:',foot.selectedMetric
    foot.image = imageMap[foot.selectedMetric.metric]
    if foot.currentPlayer.stats?.metricScores
      foot.selectedPlayerMetric = foot.currentPlayer.stats.metricScores[foot.selectedMetric.metric].score
    console.log 'foot.selectedPlayerMetric:',foot.selectedPlayerMetric

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then () ->
    foot.eliteMetrics = ef.eliteFootcontact
    foot.currentPlayer = cpf.currentPlayer
    _.each foot.eliteMetrics, (eliteMetric) -> 
      if foot.currentPlayer.stats?.metricScores?[eliteMetric.metric] 
        eliteMetric.pstats = foot.currentPlayer.stats.metricScores[eliteMetric.metric]
      else 
        eliteMetric.pstats = null
    console.log 'foot.eliteMetrics[0]:',foot.eliteMetrics[0]
    foot.setClickedRow(foot.eliteMetrics[cpf.footMetricsIndex], cpf.footMetricsIndex)

  return foot
]

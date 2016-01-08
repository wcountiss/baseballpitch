angular.module('motus').controller 'jointKineticsController', ['currentPlayerFactory','eliteFactory','$stat','$q',(currentPlayerFactory, eliteFactory, $stat, $q) ->
  # self reference
  joint = this
  # grab factory data
  cpf = currentPlayerFactory
  ef = eliteFactory

  joint.filterType = '30'

  imageMap = {
    "peakElbowCompressiveForce": "images/legend/MAX_ElbowFLexion.jpg",
    "peakElbowValgusTorque": "images/legend/MAX_ShoulderRotation.jpg",
    "peakShoulderRotationTorque": "images/legend/MAX_TrunkRotation.jpg",
    "peakShoulderCompressiveForce": "images/legend/MAX_FootHeight.jpg",
    "peakShoulderAnteriorForce": "images/legend/MAX_FootHeight.jpg",
  }

  joint.filterLastThrowType = () ->
    if joint.filterType == '30'
      _.each joint.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = joint.currentPlayer.stats.metricScores[eliteMetric.metric]
    else
      $stat.filterLastThrowType(joint.currentPlayer.pitches, joint.filterType)
      .then (stats) ->
        _.each joint.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]
  
   joint.setClickedRow = (eliteMetric, index) ->
    cpf.jointMetricsIndex = index
    joint.selectedMetric = eliteMetric
    joint.image = imageMap[joint.selectedMetric.metric]
    if joint.currentPlayer.stats?.metricScores
      joint.selectedPlayerMetric = joint.currentPlayer.stats.metricScores[joint.selectedMetric.metric].score


  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then () ->
    joint.eliteMetrics = ef.eliteKinetics
    joint.currentPlayer = cpf.currentPlayer
    _.each joint.eliteMetrics, (eliteMetric) -> 
      if joint.currentPlayer.stats?.metricScores?[eliteMetric.metric] 
        eliteMetric.pstats = joint.currentPlayer.stats.metricScores[eliteMetric.metric]
      else 
        eliteMetric.pstats = null
    joint.setClickedRow(joint.eliteMetrics[cpf.maxMetricsIndex], cpf.maxMetricsIndex)

  return joint
]

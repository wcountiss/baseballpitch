angular.module('motus').controller 'jointKineticsController', ['currentPlayerFactory','eliteFactory','$stat','$q',(currentPlayerFactory, eliteFactory, $stat, $q) ->
  # self reference
  joint = this
  # grab factory data
  cpf = currentPlayerFactory
  ef = eliteFactory

  joint.filterType = '30'
  cpf.getCurrentPlayer()

  imageMap = {
    "peakElbowCompressiveForce": "images/legend/MAX_ElbowFLexion.jpg",
    "peakElbowValgusTorque": "images/legend/MAX_ShoulderRotation.jpg",
    "peakShoulderRotationTorque": "images/legend/MAX_TrunkRotation.jpg",
    "peakShoulderCompressiveForce": "images/legend/MAX_FootHeight.jpg",
    "peakShoulderAnteriorForce": "images/legend/MAX_FootHeight.jpg",
  }

  joint.filterLastThrowType = () ->
    if joint.filterType == '30'
      _.each joint.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = joint.stats.metricScores[eliteMetric.metric]
    else
      $stat.filterLastThrowType(joint.currentPlayer.pitches, joint.filterType)
      .then (stats) ->
        _.each joint.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]
  
  joint.setClickedRow = (eliteMetric, index) ->
    cpf.jointMetricsIndex = index
    joint.selectedMetric = eliteMetric
    joint.selectedMetric.avg = Math.round(joint.selectedMetric.avg)
    joint.image = imageMap[joint.selectedMetric.metric]
    if joint.stats?.metricScores
      joint.selectedPlayerMetric = Math.round(eliteMetric.pstats.score)

  joint.setfilterCount = (pitches, type) ->
    pitchesOfType = _.filter pitches, (pitch) -> 
      if type == 'Untagged'
        return !pitch.tagString
      else
        return false if !pitch.tagString
        return pitch.tagString.split(',')[0] == type
    joint["#{type}Count"] = pitchesOfType.length


  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then (results) ->
    joint.eliteMetrics = _.filter(results[0], (metric) -> metric.categoryCode == 'K' )
    joint.currentPlayer = cpf.currentPlayer 
    console.log('THIS PLAYER: ',cpf.currentPlayer.athleteProfile.firstName) 
    $stat.runStatsEngine(joint.currentPlayer.pitches).then (stats) ->
      joint.stats = stats
      _.each joint.eliteMetrics, (eliteMetric) -> 
        if joint.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = joint.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
      joint.setClickedRow(joint.eliteMetrics[cpf.maxMetricsIndex], cpf.maxMetricsIndex)
      joint.setfilterCount(joint.currentPlayer.pitches, 'Longtoss')
      joint.setfilterCount(joint.currentPlayer.pitches, 'Bullpen')
      joint.setfilterCount(joint.currentPlayer.pitches, 'Game')
      joint.setfilterCount(joint.currentPlayer.pitches, 'Untagged')

  return joint
]

angular.module('motus').controller 'jointKineticsController', ['currentPlayerFactory','eliteFactory','$pitch','$stat','$q',(currentPlayerFactory, eliteFactory, $pitch, $stat, $q) ->
  # self reference
  joint = this
  # grab factory data
  cpf = currentPlayerFactory
  ef = eliteFactory
  joint.filterType = '30'


  imageMap = {
    "peakElbowCompressiveForce": "images/legend/MAX_ElbowFlexion.jpg",
    "peakElbowValgusTorque": "images/legend/MAX_ShoulderRotation.jpg",
    "peakShoulderRotationTorque": "images/legend/MAX_TrunkRotation.jpg",
    "peakShoulderCompressiveForce": "images/legend/MAX_FootHeight.jpg",
    "peakShoulderAnteriorForce": "images/legend/MAX_FootHeight.jpg",
  }

  joint.filterSession = () ->
    if !joint.filteredPitches
      _.each joint.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = joint.stats.metricScores[eliteMetric.metric]
    else
      $stat.runStatsEngine(joint.filteredPitches)
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


  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer(), $pitch.getPitches({ daysBack: 90 })]
  $q.all(loadPromises).then (results) ->
    joint.eliteMetrics = _.filter(results[0], (metric) -> metric.categoryCode == 'K' )
    joint.currentPlayer = cpf.currentPlayer 
    
    #group pitches into sessions
    pitches = _.filter results[2], (pitch) -> pitch.athleteProfile.objectId == cpf.currentPlayer.athleteProfile.objectId
    joint.sessions = _.groupBy pitches, (pitch) -> 
      topLevelTagString = if pitch.tagString then pitch.tagString.split(',')[0] else 'Untagged'
      return moment(pitch.pitchDate.iso).format('MM/DD/YYYY') + ':' + topLevelTagString

    #get 30 day average by default on the current player
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

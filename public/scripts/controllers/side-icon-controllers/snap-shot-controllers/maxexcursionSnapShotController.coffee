angular.module('motus').controller 'maxexcursionSnapShotController', ['currentPlayerFactory','eliteFactory','$pitch','$stat', '$q',(currentPlayerFactory, eliteFactory, $pitch, $stat, $q) ->
  max = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  max.filterType = '30'

  imageMap = {
    "maxElbowFlexion": "images/legend/MAX_ElbowFlexion.jpg",
    "maxShoulderRotation": "images/legend/MAX_ShoulderRotation.jpg",
    "maxTrunkSeparation": "images/legend/MAX_TrunkRotation.jpg",
    "maxFootHeight": "images/legend/MAX_FootHeight.jpg",
  }

  max.filterSession = () ->
    if !max.filteredPitches
      _.each max.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = max.stats.metricScores[eliteMetric.metric]
    else
      $stat.runStatsEngine(max.filteredPitches)
      .then (stats) ->
        _.each max.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]

  max.setClickedRow = (eliteMetric, index) ->
    cpf.maxMetricsIndex = index
    max.selectedMetric = eliteMetric
    max.image = imageMap[max.selectedMetric.metric]
    if max.stats?.metricScores
      max.selectedPlayerMetric = eliteMetric.pstats.score

  max.setfilterCount = (pitches, type) ->
    pitchesOfType = _.filter pitches, (pitch) -> 
      if type == 'Untagged'
        return !pitch.tagString
      else
        return false if !pitch.tagString
        return pitch.tagString.split(',')[0] == type
    max["#{type}Count"] = pitchesOfType.length

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer(), $pitch.getPitches({ daysBack: 90 })]
  $q.all(loadPromises).then (results) ->
    max.eliteMetrics = _.filter(results[0], (metric) -> metric.categoryCode == 'ME' )
    max.currentPlayer = cpf.currentPlayer
    
    #group pitches into sessions
    pitches = _.filter results[2], (pitch) -> pitch.athleteProfile.objectId == cpf.currentPlayer.athleteProfile.objectId
    max.sessions = _.groupBy pitches, (pitch) -> 
      topLevelTagString = if pitch.tagString then pitch.tagString.split(',')[0] else 'Untagged'
      return moment(pitch.pitchDate.iso).format('MM/DD/YYYY') + ':' + topLevelTagString

    #get 30 day average by default on the current player
    $stat.runStatsEngine(max.currentPlayer.pitches).then (stats) ->
      max.stats = stats
      _.each max.eliteMetrics, (eliteMetric) -> 
        if max.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = max.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
      max.setClickedRow(max.eliteMetrics[cpf.maxMetricsIndex], cpf.maxMetricsIndex)
      max.setfilterCount(max.currentPlayer.pitches, 'Longtoss')
      max.setfilterCount(max.currentPlayer.pitches, 'Bullpen')
      max.setfilterCount(max.currentPlayer.pitches, 'Game')
      max.setfilterCount(max.currentPlayer.pitches, 'Untagged')

  return max
]

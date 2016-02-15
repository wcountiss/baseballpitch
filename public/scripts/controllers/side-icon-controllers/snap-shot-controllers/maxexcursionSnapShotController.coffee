angular.module('motus').controller 'maxexcursionSnapShotController', ['currentPlayerFactory','eliteFactory','$pitch','$stat', '$q','$locHistory',(currentPlayerFactory, eliteFactory, $pitch, $stat, $q, $locHistory) ->
  max = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  max.filterType = '30'
  max.subFilters = {}
  max.subFilterHeading = 'Pitch Type' 

  $locHistory.lastLocation()


  imageMap = {
    "maxElbowFlexion": "images/legend/MAX_ElbowFlexion.jpg",
    "maxShoulderRotation": "images/legend/MAX_ShoulderRotation.jpg",
    "maxTrunkSeparation": "images/legend/MAX_TrunkRotation.jpg",
    "maxFootHeight": "images/legend/MAX_FootHeight.jpg"
  }

  max.filterSession = () ->
    pitches = max.sessions[max.filteredPitchKey] || max.currentPlayer.pitches
    if !max.filteredPitchKey
      _.each max.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = max.stats.metricScores[eliteMetric.metric]
      max.subFilterHeading = 'Pitch Type'
      max.subTag1 = null
      max.subTag2 = null
    else
      $stat.runStatsEngine(pitches)
      .then (stats) ->
        _.each max.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]
         #if longtoss the filter is by distance
        if max.filteredPitchKey.split(':')[1] == 'Longtoss'
          max.subFilterHeading = 'Distance'

    max.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)    
    max.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)

  max.subFilterChange = (sub, level) ->
    #get pitches filtered by session or 30 days
    
    pitches = max.sessions[max.filteredPitchKey] || max.currentPlayer.pitches
    if max.subTag1
      pitches = $pitch.filterTag(pitches, max.subTag1, 1)
      #update the subfilter level 2
      max.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)
    if max.subTag2
      pitches = $pitch.filterTag(pitches, max.subTag2, 2)

    #run stats on filterd pitches
    $stat.runStatsEngine(pitches)
    .then (stats) ->
      max.stats = stats
      _.each max.eliteMetrics, (eliteMetric) -> 
        if max.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = max.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
          
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

    #set subFilters
    max.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)
    max.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)


  return max
]

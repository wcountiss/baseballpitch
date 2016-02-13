angular.module('motus').controller 'footcontactSnapShotController', ['currentPlayerFactory','eliteFactory', '$pitch', '$stat', '$q',(currentPlayerFactory, eliteFactory, $pitch, $stat, $q) ->
  foot = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  foot.filterType = '30'
  foot.subFilters = {}
  foot.subFilterHeading = 'Pitch Type' 


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

  foot.filterSession = () ->
    pitches = foot.sessions[foot.filteredPitchKey] || foot.currentPlayer.pitches
    if !foot.filteredPitchKey
      _.each foot.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = foot.stats.metricScores[eliteMetric.metric]
      foot.subFilterHeading = 'Pitch Type'
      foot.subTag1 = null
      foot.subTag2 = null
    else
      $stat.runStatsEngine(pitches)
      .then (stats) ->
        _.each foot.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]
         #if longtoss the filter is by distance
        if foot.filteredPitchKey.split(':')[1] == 'Longtoss'
          foot.subFilterHeading = 'Distance'

    foot.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)    
    foot.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)

  foot.subFilterChange = (sub, level) ->
    #get pitches filtered by session or 30 days
    pitches = foot.sessions[foot.filteredPitchKey] || foot.currentPlayer.pitches
    if foot.subTag1
      pitches = $pitch.filterTag(pitches, foot.subTag1, 1)
      #update the subfilter level 2
      foot.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)
    if foot.subTag2
      pitches = $pitch.filterTag(pitches, foot.subTag2, 2)

    #run stats on filterd pitches
    $stat.runStatsEngine(pitches)
    .then (stats) ->
      foot.stats = stats
      _.each foot.eliteMetrics, (eliteMetric) -> 
        if foot.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = foot.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null

  foot.setClickedRow = (eliteMetric,index) ->
    cpf.footMetricsIndex = index
    foot.selectedMetric = eliteMetric
    foot.image = imageMap[foot.selectedMetric.metric]
    if foot.stats?.metricScores
      foot.selectedPlayerMetric = eliteMetric.pstats.score

  foot.setfilterCount = (pitches, type) ->
    pitchesOfType = _.filter pitches, (pitch) -> 
      if type == 'Untagged'
        return !pitch.tagString
      else
        return false if !pitch.tagString
        return pitch.tagString.split(',')[0] == type
    foot["#{type}Count"] = pitchesOfType.length

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer(), $pitch.getPitches({ daysBack: 90 })]
  $q.all(loadPromises).then (results) ->
    foot.eliteMetrics = _.filter(results[0], (metric) -> metric.categoryCode == 'FC' )
    foot.currentPlayer = cpf.currentPlayer
    
    #group pitches into sessions
    pitches = _.filter results[2], (pitch) -> pitch.athleteProfile.objectId == cpf.currentPlayer.athleteProfile.objectId
    foot.sessions = _.groupBy pitches, (pitch) -> 
      topLevelTagString = if pitch.tagString then pitch.tagString.split(',')[0] else 'Untagged'
      return moment(pitch.pitchDate.iso).format('MM/DD/YYYY') + ':' + topLevelTagString

    #get 30 day average by default on the current player
    $stat.runStatsEngine(foot.currentPlayer.pitches).then (stats) ->
      foot.stats = stats

      _.each foot.eliteMetrics, (eliteMetric) -> 
        if foot.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = foot.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
      foot.setClickedRow(foot.eliteMetrics[cpf.footMetricsIndex], cpf.footMetricsIndex)
      foot.setfilterCount(foot.currentPlayer.pitches, 'Longtoss')
      foot.setfilterCount(foot.currentPlayer.pitches, 'Bullpen')
      foot.setfilterCount(foot.currentPlayer.pitches, 'Game')
      foot.setfilterCount(foot.currentPlayer.pitches, 'Untagged')

    #set subFilters
    foot.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)
    foot.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)

  return foot
]

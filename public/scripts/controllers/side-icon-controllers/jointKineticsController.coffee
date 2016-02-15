angular.module('motus').controller 'jointKineticsController', ['currentPlayerFactory','eliteFactory','$pitch','$stat','$q','$locHistory',(currentPlayerFactory, eliteFactory, $pitch, $stat, $q, $locHistory) ->
  # self reference
  joint = this
  # grab factory data
  cpf = currentPlayerFactory
  ef = eliteFactory
  joint.filterType = '30'
  joint.subFilters = {}
  joint.subFilterHeading = 'Pitch Type'

  $locHistory.lastLocation()
   


  imageMap = {
    "peakElbowCompressiveForce": "images/legend/MAX_ElbowFlexion.jpg",
    "peakElbowValgusTorque": "images/legend/MAX_ShoulderRotation.jpg",
    "peakShoulderRotationTorque": "images/legend/MAX_TrunkRotation.jpg",
    "peakShoulderCompressiveForce": "images/legend/MAX_FootHeight.jpg",
    "peakShoulderAnteriorForce": "images/legend/MAX_FootHeight.jpg",
  }

  joint.filterSession = () ->
    pitches = joint.sessions[joint.filteredPitchKey] || joint.currentPlayer.pitches
    joint.subTag1 = null
    joint.subTag2 = null
    if !joint.filteredPitchKey
      _.each joint.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = joint.stats.metricScores[eliteMetric.metric]
      joint.subFilterHeading = 'Pitch Type'
    else
      $stat.runStatsEngine(pitches)
      .then (stats) ->
        _.each joint.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]
      
      #if longtoss the filter is by distance
      joint.subFilterHeading =  if joint.filteredPitchKey.split(':')[1] == 'Longtoss' then 'Distance' else 'Pitch Type'


    joint.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)    
    joint.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)

  joint.subFilterChange = (sub, level) ->
    #get pitches filtered by session or 30 days
    
    pitches = joint.sessions[joint.filteredPitchKey] || joint.currentPlayer.pitches
    if joint.subTag1
      pitches = $pitch.filterTag(pitches, joint.subTag1, 1)
      #update the subfilter level 2
      joint.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)
    if joint.subTag2
      pitches = $pitch.filterTag(pitches, joint.subTag2, 2)

    #run stats on filterd pitches
    $stat.runStatsEngine(pitches)
    .then (stats) ->
      joint.stats = stats
      _.each joint.eliteMetrics, (eliteMetric) -> 
        if joint.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = joint.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
          
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

    #set subFilters
    joint.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)
    joint.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)

  return joint
]

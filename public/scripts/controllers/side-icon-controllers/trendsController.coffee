angular.module('motus').controller 'trendsController', ['$scope', '$q','currentPlayerFactory','eliteFactory', '$pitch', '$stat',($scope, $q, currentPlayerFactory, eliteFactory, $pitch, $stat) ->

  trends = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  tags = ['Longtoss', 'Bullpen', 'Game', 'Untagged']

  #default all checked
  trends.filter = {Longtoss: true, Bullpen: true, Game: true, Untagged: true}

  #Accordion State open or closed
  trends.isOpen = { foot: false, hip: false, trunk: false, shoulder: false, elbow: false }

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer(), $pitch.getPitches({ daysBack: 90 })]
  $q.all(loadPromises).then (results) ->
    trends.eliteMetrics = results[0]
    trends.currentPlayer = cpf.currentPlayer
    trends.pitches = _.filter results[2], (pitch) -> pitch.athleteProfile.objectId == cpf.currentPlayer.athleteProfile.objectId
    trends.selectMetric(trends.eliteMetrics[0])

    #Create footJoint array for the accordion
    trends.footJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'FOOT'
        return obj
    #Create hipJoint array for the accordion
    trends.hipJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'HIP'
        return obj

    #Create trunkJoint array for the accordion
    trends.trunkJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'TRUNK'
        return obj

    #Create shoulderJoint array for the accordion
    trends.shoulderJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'SHOULDER'
        return obj

    #Create elbowJoint array for the accordion
    trends.elbowJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'ELBOW'
        return obj

  getPitches = () ->
    #group the pitches into sessions and tags
    pitches = _.groupBy trends.pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/DD/YYYY')
    pitches = pitches[trends.selectedSession.date]

    #what is selected
    pitches = $pitch.filterTag(pitches, trends.selectedSession.tag)

    return pitches

  subFilterPitches = () ->
    pitches = getPitches()

    filteredPitches = []
    _.each _.keys(trends.subFilters.level1), (subFilterKey) ->
      if (trends.subFilters.level1[subFilterKey])
        filteredPitches = filteredPitches.concat $pitch.filterTag(pitches, subFilterKey, 1)
    pitches = filteredPitches

    _.each _.keys(trends.subFilters.level2), (subFilterKey) ->
      if (trends.subFilters.level2[subFilterKey])
        filteredPitches = filteredPitches.concat $pitch.filterTag(pitches, subFilterKey, 2)

    return filteredPitches


  bindLineChart = (selectedPlayerDetailPitches) ->
    #sort the pitches
    selectedPlayerDetailPitches = _.sortBy selectedPlayerDetailPitches, (pitch) -> moment(pitch.pitchDate.iso)

    scores = _.map selectedPlayerDetailPitches, (pitch, i) -> { index: i+1, score: pitch[trends.selectedMetric.metric]}

    if !scores.length
      trends.playerDetailScores = null
    else
      #filter the trend chart down to the clicked element and rebind to detail chart
      trends.playerDetailScores = {
        average: trends.playerScores.average,
        units: trends.playerScores.units
        yMin: trends.playerScores.yMin
        yMax: trends.playerScores.yMax
        yType: trends.playerScores.yType
        scores: scores
      }

  trends.groupClick = (element) ->
    #Make header based on the selected elements
    trends.selectedSession = { date: element.group, tag: element.name }

    selectedPlayerDetailPitches = getPitches()

    #get subfilters and set them to true
    trends.subFilters = {}
    trends.subFilters.level1 = {}
    trends.subFilters.level2 = {}
    subFilters = $pitch.uniquefilterTags(selectedPlayerDetailPitches, 1)
    _.each subFilters, (subFilter) -> trends.subFilters.level1[subFilter] = true

    subFilters = $pitch.uniquefilterTags(selectedPlayerDetailPitches, 2)
    _.each subFilters, (subFilter) -> trends.subFilters.level2[subFilter] = true


    bindLineChart(selectedPlayerDetailPitches)

    if !element.firstLoad
      $scope.$apply()

  getStats = (sessionPitches, metric) ->
    statsPromises = [
      $stat.filterLastThrowType(sessionPitches, 'Longtoss')
      $stat.filterLastThrowType(sessionPitches, 'Bullpen')
      $stat.filterLastThrowType(sessionPitches, 'Game')
      $stat.filterLastThrowType(sessionPitches, 'Untagged')
    ]
    $q.all(statsPromises)
    .then (stats) ->
      return {
        Longtoss: stats[0]?.metricScores[metric.metric].score,
        Bullpen: stats[1]?.metricScores[metric.metric].score,
        Game: stats[2]?.metricScores[metric.metric].score,
        Untagged: stats[3]?.metricScores[metric.metric].score
      }

  trends.subFilterChange = (sub, level) ->
    trends.subFilters["level#{level}"][sub] = !trends.subFilters["level#{level}"][sub]
    selectedPlayerDetailPitches = subFilterPitches()
    bindLineChart(selectedPlayerDetailPitches)

    #rebind sublevel 2 if you change level 1
    if level == 1
      subFilters = $pitch.uniquefilterTags(selectedPlayerDetailPitches, 2)
      _.each subFilters, (subFilter) -> trends.subFilters.level2[subFilter] = true

  trends.filterChange = () ->
    trends.selectMetric(trends.selectedMetric)


  #select metric and map to the chart
  trends.selectMetric = (metric) ->
    #blank out detail chart
    trends.playerDetailScores = null

    #Grab the current metric.label and place it into trends.accordionSelected
    #This will add the propper CSS to the selected metric
    trends.accordionSelected = metric.title
    trends.selectedMetric = metric

    #group the pitches into sessions and tags
    pitches = _.groupBy trends.pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/DD/YYYY')

    groups = []
    statsPromises = []
    _.each _.keys(pitches), (sessionKey) ->
      sessionPitches = pitches[sessionKey]
      statsPromises.push getStats(sessionPitches, metric).then (sessionStats) ->
        groupStats = _.extend({date: sessionKey}, sessionStats)
        groups.push groupStats

    $q.all(statsPromises)
    .then () ->
      if groups.length
        groups = _.sortBy(groups, (group) -> moment(group.date))

        #set detail chart with default clicks of last session
        # selectOne = false
        defaultSelected = null
        selectOne = false
        _.each tags, (tag) ->
          if !selectOne && groups[groups.length-1][tag]
            selectOne = true
            defaultSelected = {date: groups[groups.length-1].date, name: tag }

        trends.playerScores = {
          heading: metric.label,
          units: metric.units,
          average: metric.avg
          keys: _.filter _.keys(trends.filter), (key) ->
            if trends.filter[key]
              return key # ['Longtoss', 'Bullpen', 'Game', 'Untagged']
          groups: groups
          yMin: metric.yMin
          yMax: metric.yMax
          yType: metric.yType
          defaultSelected: defaultSelected
        }

        if defaultSelected
          trends.groupClick({group: groups[groups.length-1].date, name: defaultSelected.name, selected: true, firstLoad: true})


  return trends
]

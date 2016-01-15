angular.module('motus').controller('teamOverviewController',

  ['$http', '$state', '$q', '$player', '$pitch', '$stat', '$scope'
    ($http, $state, $q, $player, $pitch, $stat, $scope) ->
      team = this

      #Get pitches a year back
      $pitch.getPitches({ daysBack: 365 })
      .then (pitches) ->
        #group pitches by month
        pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/01/YYYY')
        #run engine through all pitches per month
        statsPromises = []
        _.each _.keys(pitches), (key) -> statsPromises.push $stat.runStatsEngine(pitches[key])
        $q.all(statsPromises)
        .then (stats) ->
          #map overall score per month
          scores = _.map _.keys(pitches), (key, i) -> return { date: moment(key, "MM/DD/YYYY").startOf('month').format('MM/YYYY'), score: stats[i].overallScore.ratingScore}
          team.teamScores = scores

      #get the awards
      team.myteam = $player.getPlayers()
      .then (players) ->
        team.bullpen = players
         
        $stat.getPlayerAwards(players)
        .then (awards) ->
          judgements = {
            'Best Performer': {title: 'Best', subtitle: 'Performer'},
            'Worst Performer': {title: 'Worst', subtitle: 'Performer'},
            'Most Improved': {title: 'Improved', subtitle: 'Most Since Last Month'},
            'Most Regressed': { title: 'Regressed', subtitle: 'Most Since Last Month'},
            'Highest Elbow Torque': { title: 'Highest', subtitle: 'Elbow Torque'},
            'Lowest Elbow Torque': { title: 'Lowest', subtitle: 'Elbow Torque'}
          }
          team.awardedPlayers = _.map awards, (award) ->
            award.awardtitle = judgements[award.award].title
            award.awardsub = judgements[award.award].subtitle
            return award
    
      return team
  ])

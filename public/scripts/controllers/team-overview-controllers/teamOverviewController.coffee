angular.module('motus').controller('teamOverviewController',

  ['$http', '$state', '$q', 'eliteFactory', '$player', '$pitch', '$stat', '$scope'
    ($http, $state, $q, $elite, $player, $pitch, $stat, $scope) ->
      team = this

      #cache upfront
      #Get pitches a year back
      GetAllDataPromises = [$elite.getEliteMetrics(), $pitch.getPitches({ daysBack: 365 })]
      $q.all(GetAllDataPromises)
      .then (result) ->
        pitches = result[1]        
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
          
          $stat.getPlayersStats(players)
          .then (playerStats) ->
            console.log playerStats
            team.bullpen = playerStats

          $stat.getPlayerAwards(players)
          .then (awards) ->
            judgements = {
              'Best Performer': {iconpath: 'bestmechanics.svg', title: 'Best', subtitle: 'Performer', order: 1},
              'Worst Performer': {iconpath: 'worstmechanics.svg', title: 'Worst', subtitle: 'Performer', order: 4},
              'Most Improved': {iconpath: 'mostimproved.svg', title: 'Improved', subtitle: 'Most Since Last Month', order: 2},
              'Most Regressed': {iconpath: 'mostregressed.svg', title: 'Regressed', subtitle: 'Most Since Last Month', order: 5},
              'Highest Elbow Torque': {iconpath: 'worsttorque.svg', title: 'Highest', subtitle: 'Elbow Torque', order: 6},
              'Lowest Elbow Torque': {iconpath: 'besttorque.svg', title: 'Lowest', subtitle: 'Elbow Torque', order: 3}
            }
            awardedPlayers = _.map awards, (award) ->
              award.awardtitle = judgements[award.award].title
              award.awardsub = judgements[award.award].subtitle
              award.order = judgements[award.award].order
              award.iconpath = judgements[award.award].iconpath

              return award
            awardedPlayers = _.sortBy awardedPlayers, (awardedPlayer) -> awardedPlayer.order
            team.awardedPlayers = awardedPlayers


      return team
  ])

angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$q', '$player', '$stat'
    ($http, $state, $q, $player, $stat) ->
      team = this

      $http.post("pitch", { daysBack: 365 })
      .success (pitches) ->
        #group pitches by month
        pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/YYYY')
        #run engine through all pitches per month
        statsPromises = []
        _.each _.keys(pitches), (key) -> statsPromises.push $stat.runStatsEngine(pitches[key])
        $q.all(statsPromises)
        .then (stats) ->
          console.log stats

          #map overall score per month
          scores = _.map stats, (monthStat, i) -> return { date: moment(pitches[i]).startOf('month').format('MM/YYYY'), score: monthStat.overallScore.ratingScore}
          #Remove when we have a month of data
          scores.push { date:"12/01/2014", score: 90 }
          team.teamScores = scores

      team.myteam = $player.getPlayers()
      .then (players) ->

        console.log(players)
        team.bullpen = players
         
        $stat.getPlayerAwards(players)
        .then () ->
          console.log "PLAYERS OBJECT:" ,players

      return team
  ])

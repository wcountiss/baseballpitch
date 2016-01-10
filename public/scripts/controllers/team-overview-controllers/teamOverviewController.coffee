angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$q', '$player', '$stat'
    ($http, $state, $q, $player, $stat) ->
      team = this

      $http.post("pitch", { daysBack: 365 })
      .success (pitches) ->
        #group pitches by month
        pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).month()+1
        #run engine through all pitches per month
        statsPromises = []
        _.each _.keys(pitches), (month) ->
          statsPromises.push $stat.runStatsEngine(pitches[month])
        $q.all(statsPromises)
        .then (stats) ->
          console.log stats
        #map overall score per month

        #transform data by month

          #Map to teamScores
          team.teamScores = [
            {date:'1-May-12', score: 87.4},
            {date:'30-Apr-12', score: 58.3}
          ]


      team.myteam = $player.getPlayers()
      .then (players) ->

        console.log(players)
        team.bullpen = players
         
          
          # $stat.getPlayerAwards(players)
          # .then () ->
          #   team.players = players


      team
  ])

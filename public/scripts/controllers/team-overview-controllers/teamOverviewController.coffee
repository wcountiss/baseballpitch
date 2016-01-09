angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$player', '$stat'
    ($http, $state, $player, $stat) ->
      team = this

      $http.post("pitch", { daysBack: 365 })
      .success (pitches) ->
        console.log pitches


      team.myteam = $player.getPlayers()
      .then (players) ->

        console.log(players)
        team.bullpen = players
         
          
          # $stat.getPlayerAwards(players)
          # .then () ->
          #   team.players = players


      team
  ])

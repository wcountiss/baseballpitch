angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$player', '$stat'
    ($http, $state, $player, $stat) ->
      team = this

      
      team.myteam = $player.getPlayers()
      .then (players) ->

        console.log(players)
        team.bullpen = players
         
          
          # $stat.getPlayerAwards(players)
          # .then () ->
          #   team.players = players


      team
  ])

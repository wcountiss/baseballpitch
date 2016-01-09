angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$player', '$stat'
    ($http, $state, $player, $stat) ->
      team = this
      console.log( "SHOW IT:",team.myteam)


      

      team.hello = "hello"
      team.myteam = $player.getPlayers()
        .then (players) ->
         return players
          
          # $stat.getPlayerAwards(players)
          # .then () ->
          #   team.players = players


      team
  ])

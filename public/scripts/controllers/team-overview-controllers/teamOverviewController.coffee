angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$player', '$stat'
    ($http, $state, $player, $stat) ->
      team = this
      console.log 'hello team'

      team.hello = "hello"
      $player.getPlayers()
        .then (players) ->
          $stat.getPlayerAwards(players)
          .then () ->
            team.players = players


      team
  ])

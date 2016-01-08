angular.module('motus').controller('teamOverviewController',
  ['$scope', '$http', '$state', '$player', '$stat'
    ($scope, $http, $state, $player, $stat) ->
      to = this

      debugger
      $player.getPlayers()
      .then (players) ->
        debugger;
        $stat.getPlayerAwards(players)
        .then () ->
          console.log players
          to.players = players

      return to
  ])

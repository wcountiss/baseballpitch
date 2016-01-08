angular.module('motus').controller('teamOverviewController',
  ['$scope', '$http', '$state', '$player', '$stat'
    ($scope, $http, $state, $player, $stat) ->
      to = this

      $player.getPlayers()
      .then (players) ->
        $stat.getPlayerAwards(players)
        .then () ->
          console.log players
          to.players = players

      return to
  ])

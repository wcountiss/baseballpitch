angular.module('motus').service('$player', ['$http', '$q', '$stat', ($http, $q, $stat) ->
  playerService = this

  #get players, pitches and stats
  playerService.getPlayers = () =>
      if playerService.players
        return $q.when(playerService.players)
      else
        defer = $q.defer()
        playerCalls = [$http.post("player"),$http.post("pitch")]
        $q.all(playerCalls)
        .then (results) ->
          players = results[0].data
          pitches = results[1].data
          _.each players, (player) -> player.pitches = _.filter(pitches, (pitch) -> pitch.athleteProfile.objectId == player.athleteProfile.objectId )
          $stat.getPlayersStats(players)
          .then (players) -> 
            defer.resolve(players)
        return defer.promise

  #get pitches
  playerService.getPitches = (options) =>
    defer = $q.defer()
    $http.post("pitch", options)
    .success (pitches) ->
      defer.resolve(pitches)
    return defer.promise

  return playerService
])
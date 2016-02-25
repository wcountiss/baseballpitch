angular.module('motus').service('$player', ['$http', '$q', '$stat', '$pitch', ($http, $q, $stat, $pitch) ->
  ps = this

  #get players, pitches and stats
  ps.getPlayers = (options) =>
    if !options?.noCache && ps.playerRoster
      return $q.when(ps.playerRoster)
    else
      defer = $q.defer()
      playerCalls = [$http.post("player"), $pitch.getPitches()]
      $q.all(playerCalls)
      .then (results) ->
        players = results[0].data
        pitches = results[1]
        _.each players, (player) -> player.pitches = _.filter(pitches, (pitch) -> pitch.athleteProfile.objectId == player.objectId )
        players = $stat.getPlayersDidThrowType(players)
        ps.playerRoster = players
        defer.resolve(players)
      .catch (error) ->
        defer.reject(error)
      return defer.promise

  return ps
])

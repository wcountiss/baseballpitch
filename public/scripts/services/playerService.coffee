angular.module('motus').service('$player', ['$http', '$q', '$stat', '$pitch', ($http, $q, $stat, $pitch) ->
  ps = this

  #get players, pitches and stats
  ps.getPlayers = () =>
    if ps.playerRoster
      return $q.when(ps.playerRoster)
    else
      defer = $q.defer()
      playerCalls = [$http.post("player"), $pitch.getPitches()]
      $q.all(playerCalls)
      .then (results) ->
        players = results[0].data
        pitches = results[1]
        _.each players, (player) -> player.pitches = _.filter(pitches, (pitch) -> pitch.athleteProfile.objectId == player.athleteProfile.objectId )
        players = $stat.getPlayersDidThrowType(players)
        ps.playerRoster = players
        defer.resolve(players)
      return defer.promise

  return ps
])

cachedPlayers = null

angular.module('motus').service('$player', ['$http', '$q', '$stat', '$pitch', ($http, $q, $stat, $pitch) ->
  playerService = this

  #get players, pitches and stats
  playerService.getPlayers = () =>
    console.log("THIS FIRED")
    if cachedPlayers
      return $q.when(cachedPlayers)
    else
      defer = $q.defer()
      playerCalls = [$http.post("player"), $pitch.getPitches()]
      $q.all(playerCalls)
      .then (results) ->
        players = results[0].data
        pitches = results[1]
        _.each players, (player) -> player.pitches = _.filter(pitches, (pitch) -> pitch.athleteProfile.objectId == player.athleteProfile.objectId )
        players = $stat.getPlayersDidThrowType(players)
        cachedPlayers = players
        defer.resolve(players)
      return defer.promise

  return playerService
])
angular.module('motus').service('$stat', ['$http','$q', 'eliteFactory', ($http, $q, eliteFactory) ->
  stat = this
  
  stat.getPlayersStats = (players) =>
    return $q.when(
      eliteFactory.getEliteMetrics()
      .then (eliteMetrics) ->
        _.each players, (player) -> player.stats = []
        return players
    )

  return stat
])
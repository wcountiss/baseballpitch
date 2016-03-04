angular.module('motus').controller('indexController',
['$state', '$http', '$cookies', '$currentUser', '$q', '$pitch', '$player',
  ($state, $http, $cookies, $currentUser, $q, $pitch, $player) ->
    index = this

    index.state = $state
    #if logged in set the current user
    index.loadUser = () ->
      stateDefer = $q.defer()
      if $cookies.get('motus')
        $http.get('/user')
        .success (user) ->
          $currentUser.user = user
          index.user = $currentUser.user
          stateDefer.resolve()
      else
        index.user = $currentUser.user
      return stateDefer.promise


    index.logOut = () ->
      $cookies.remove('motus')
      $player.clearCache()
      $pitch.clearCache()
      $state.go('login')

    index.openMenu = false;
    #Page Load
    index.loadUser()

    return index
])

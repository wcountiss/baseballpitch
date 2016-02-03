angular.module('motus').controller('indexController',
['$state', '$http', '$cookies', '$currentUser', '$q',
  ($state, $http, $cookies, $currentUser, $q) ->
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
      # $state.go('login')
      $state.go('login')

    #Page Load
    index.loadUser()

    return index
])

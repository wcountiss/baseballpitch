angular.module('motus').controller('indexController', 
['$scope', '$state', '$http', '$cookies', '$currentUser'
  ($scope, $state, $http, $cookies, $currentUser) ->
    $scope.state = $state

    #if logged in set the current user
    $scope.loadUser = () ->
      if $cookies.get('motus')
        $http.get('/user')
        .success (user) ->
          $currentUser.user = user
          $scope.user = $currentUser.user
      else
        $scope.user = $currentUser.user

    $scope.logOut = () ->
      $cookies.remove('motus')
      # $state.go('login')
      window.location = '?#/login'

    #Page Load
    $scope.loadUser()
])      
     
angular.module('motus').controller('indexController', 
['$scope', '$state', '$cookies'
  ($scope, $state, $cookies) ->
    $scope.state = $state

    $scope.logOut = () ->
      $cookies.remove('motus')
      $state.go('login')

])      
     
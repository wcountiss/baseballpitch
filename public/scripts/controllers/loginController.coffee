angular.module('motus').controller('loginController',
['$scope','$http','$cookies','$state'
  ($scope, $http, $cookies, $state) ->
    $scope.login = () ->
      $http.post("auth/login",  { email: $scope.email, password: $scope.password })
      .success (result) ->
        $state.go('player.home')
      .error (error) ->
        console.log error
])

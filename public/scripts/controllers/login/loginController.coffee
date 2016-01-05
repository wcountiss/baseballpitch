angular.module('motus').controller('loginController',
['$scope','$http','$cookies','$state', '$currentUser'
  ($scope, $http, $cookies, $state, $currentUser) ->
    $scope.login = () ->
      $http.post("auth/login",  { email: $scope.email, password: $scope.password })
      .success (user) ->
        $currentUser.user = user
        $scope._indexController.loadUser()
        $state.go('player.home')
      .error (error) ->
        $scope.error = true;
])

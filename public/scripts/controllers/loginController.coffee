angular.module('motus').controller('loginController', 
['$scope','$http','$cookies','$state'
  ($scope, $http, $cookies, $state) ->
    $scope.signUp = () ->
      $http.post("auth/signUp",  { email: $scope.email, password: $scope.password })
      .success (result) ->
        console.log result


    $scope.login = () ->
      event.preventDefault();
      $http.post("auth/login",  { email: $scope.email, password: $scope.password })
      .success (result) ->
        $state.transitionTo('player')
      .error (error) ->
        debugger;
])      
     
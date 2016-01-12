angular.module('motus').controller('loginController',
['$http','$cookies','$state', '$location', '$currentUser'
  ($http, $cookies, $state, $location, $currentUser) ->
    ctrl = this
    
    ctrl.login = () ->
      $http.post("auth/login",  { email: ctrl.email, password: ctrl.password })
      .success (user) ->
        $currentUser.user = user
        $location.url('/?#/team')
      .error (error) ->
        ctrl.error = true;

    return ctrl
])

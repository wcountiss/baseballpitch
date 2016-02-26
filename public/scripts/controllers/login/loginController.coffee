angular.module('motus').controller('loginController',
['$http','$cookies','$state', '$location', '$scope', '$currentUser'
  ($http, $cookies, $state, $location, $scope, $currentUser) ->
    ctrl = this
    
    $scope.index.loaded = true

    #Log in the user
    ctrl.login = () ->
      $http.post("auth/login",  { email: ctrl.email, password: ctrl.password })
      .success (user) ->
        $currentUser.user = user
        $scope.index.loaded = false
        $location.url('/team')
        $scope.index.loadUser()
      .error (error) ->
        if error?.error
          ctrl.invitationKeyError = error        
        else
          ctrl.error = true;

    ctrl.assignInvitationKey = () ->
      $http.post("auth/assignInvitationKey",  { email: ctrl.email, password: ctrl.password, invitationKey: ctrl.invitationKey })
      .success (user) ->
        $currentUser.user = user
        $scope.index.loaded = false
        $location.url('/team')
        $scope.index.loadUser()
      .error (error) ->
        if error?.error
          ctrl.invitationKeyError = error        
        else
          ctrl.error = true;

    return ctrl
])

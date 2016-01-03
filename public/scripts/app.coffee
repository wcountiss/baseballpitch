app = angular.module('motus', [
  'ui.router'
  'ngCookies'
  'd3'
  'ngAnimate'
])


app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise("/player/home");
  $stateProvider
  .state('login', {
    url: "/login",
    templateUrl: "views/login.html",
    controller: 'loginController'
    authenticate: false
  })
  $stateProvider
  .state('forgotPassword', {
    url: "/forgotPassword",
    templateUrl: "views/forgotPassword.html",
    controller: 'forgotPasswordController'
    authenticate: false
  })
  .state('player', {
    url: "/player",
    templateUrl: "views/player.html",
    controller: 'playerController'
    authenticate: true
  })
  .state('player.home', {
    url: '/home',
    templateUrl: 'views/player-analysis-views/home.html',
    authenticate: true
  })
  .state('player.kinetic-chain',{
    url: '/kinetic-chain',
    templateUrl: 'views/player-analysis-views/kinetic-chain.html',
    authenticate: true
  })
  .state('player.foot-contact',{
    url: '/foot-contact',
    templateUrl: 'views/player-analysis-views/foot-contact.html',
    authenticate: true
  })
  .state('player.ball-release',{
    url: '/ball-release',
    templateUrl: 'views/player-analysis-views/ball-release.html',
    authenticate: true
  })
  .state('player.max-excursion',{
    url: '/max-excursion',
    templateUrl: 'views/player-analysis-views/max-excursion.html',
    authenticate: true
  })
  .state('player.joint-kinetics',{
    url: '/joint-kinetics',
    templateUrl: 'views/player-analysis-views/joint-kinetics.html',
    authenticate: true
  })
  .state('player.trends',{
    url: '/trends',
    templateUrl: 'views/player-analysis-views/trends.html',
    authenticate: true
  })
  .state('admin', {
    url: "/admin",
    templateUrl: "views/admin.html",
    controller: 'adminController'
    authenticate: true
  })

app.run ($rootScope, $state, $cookies) ->
  $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
    #if not logged in, go to login screen
    if (toState.authenticate && !$cookies.get('motus'))
      #User isn’t authenticated, not sure why I have to do this
      window.location = '?#/login'
      # $state.go("login")

require './controllers/indexController.coffee'
require './controllers/playerController.coffee'
require './controllers/loginController.coffee'
require './controllers/forgotPasswordController.coffee'
require './controllers/adminController.coffee'

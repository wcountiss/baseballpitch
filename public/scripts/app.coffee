app = angular.module('motus', [
  'ui.router'
  'ngCookies'
  'd3'
  'ngAnimate'
  'ngTouch',
  'ui.bootstrap'
])


app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise ($injector, $location) ->
    $state = $injector.get("$state")
    $state.go("teamOverview")

  $stateProvider
  .state('login', {
    url: "/login",
    templateUrl: "views/login/login.html",
    controller: 'loginController as ctrl'
    authenticate: false
  })
  $stateProvider
  .state('forgotPassword', {
    url: "/forgotPassword",
    templateUrl: "views/login/forgotPassword.html",
    controller: 'forgotPasswordController as ctrl'
    authenticate: false
  })
  .state('teamOverview', {
    url: "/team",
    views: {
      '': {
        controller:'teamOverviewController as team',
        templateUrl: "views/team-overview/teamOverview.html"
      },
      'judgement@teamOverview': {templateUrl: 'views/team-overview/overview-templates/judgement.html'},
      'bullpen@teamOverview': {templateUrl: 'views/team-overview/overview-templates/bullpen.html'},
      'roster@teamOverview': {templateUrl: 'views/team-overview/overview-templates/roster-chart.html'}
    },
    authenticate: true
  })
  .state('player', {
    url: "/player",
    views: {
      '': {templateUrl: "views/player.html", controller: 'playerController as pc'}
    },
    authenticate: true
  })
  .state('player.home', {
    url: '/home',
    templateUrl: 'views/player-analysis-views/home.html',
    controller: 'homeController as home',
    authenticate: true
  })
  .state('player.home.accordion', {
    url: '/accordion',
    templateUrl: 'views/accordion-test.html',
    controller: 'homeController as home',
    authenticate: true
  })
  .state('player.home.overview', {
    url: '/overview',
    templateUrl: 'views/player-analysis-views/player-home-sub-views/home-overview.html',
    controller: 'playerController as pc',
    authenticate: true
  })
  .state('player.home.trends', {
    url: '/trends',
    templateUrl: 'views/player-analysis-views/player-home-sub-views/home-trends.html',
    controller: 'homeController as home',
    authenticate: true
  })
  .state('player.home.profile', {
    url: '/profile',
    templateUrl: 'views/player-analysis-views/player-home-sub-views/home-profile.html',
    controller: 'homeController as home',
    authenticate: true
  })
  .state('player.kinetic-chain',{
    url: '/kinetic-chain',
    templateUrl: 'views/player-analysis-views/kinetic-chain.html',
    controller: 'kineticChainController as chain',
    authenticate: true
  })
  .state('player.foot-contact',{
    url: '/foot-contact',
    templateUrl: 'views/player-analysis-views/foot-contact.html',
    authenticate: true,
    controller: 'footcontactSnapShotController as foot'
  })
  .state('player.ball-release',{
    url: '/ball-release',
    templateUrl: 'views/player-analysis-views/ball-release.html',
    authenticate: true,
    controller: 'ballreleaseSnapShotController as ball'
  })
  .state('player.max-excursion',{
    url: '/max-excursion',
    templateUrl: 'views/player-analysis-views/max-excursion.html',
    authenticate: true,
    controller: 'maxexcursionSnapShotController as max'
  })
  .state('player.joint-kinetics',{
    url: '/joint-kinetics',
    templateUrl: 'views/player-analysis-views/joint-kinetics.html',
    controller: 'jointKineticsController as joint',
    authenticate: true
  })
  .state('player.trends',{
    url: '/trends',
    templateUrl: 'views/player-analysis-views/trends.html',
    controller: 'trendsController as trends',
    authenticate: true
  })

app.run ($rootScope, $state, $cookies, $location) ->
  $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
    #if not logged in, go to login screen
    if (toState.authenticate && !$cookies.get('motus'))
      #User isn’t authenticated
      $location.url('/#/login');
      $state.go('login')
      event.preventDefault();

_.mixin(s.exports());
require './directives/d3-charts.js'
require './services/currentPlayerFactory.coffee'
require './services/currentUserFactory.coffee'
require './services/statService.coffee'
require './services/playerService.coffee'
require './services/pitchService.coffee'
require './controllers/indexController.coffee'
require './services/eliteFactory.coffee'
require './controllers/team-overview-controllers/teamOverviewController.coffee'
require './controllers/playerController.coffee'
require './controllers/login/loginController.coffee'
require './controllers/login/forgotPasswordController.coffee'
require './controllers/side-icon-controllers/snap-shot-controllers/ballreleaseSnapShotController.coffee'
require './controllers/side-icon-controllers/snap-shot-controllers/footcontactSnapShotController.coffee'
require './controllers/side-icon-controllers/snap-shot-controllers/maxexcursionSnapShotController.coffee'
require './controllers/side-icon-controllers/homeController.coffee'
require './controllers/side-icon-controllers/kineticChainController.coffee'
require './controllers/side-icon-controllers/jointKineticsController.coffee'
require './controllers/side-icon-controllers/trendsController.coffee'

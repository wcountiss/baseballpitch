app = angular.module('motus', [
  'ui.router'
  'ngCookies'
  'd3'
  'ngAnimate'
  'ngTouch',
  'ui.bootstrap'
])

require './services/playerService.coffee'
require './services/pitchService.coffee'
require './services/eliteFactory.coffee'

app.service 'initService', ($q, eliteFactory, $player) ->
  return {
    cache: () ->
      cachedPromises = [eliteFactory.getEliteMetrics(), $player.getPlayers()]
      $q.all(cachedPromises)
      .catch (error) ->
        console.log error
        throw error
  }

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
  .state('error', {
    url: "/error",
    templateUrl: "views/error.html"
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
    authenticate: true,
    resolve: {
      init: (initService) ->
        initService.cache()
    }
  })
  .state('player', {
    url: "/player",
    views: {
      '': {templateUrl: "views/player.html", controller: 'playerController as pc'}
    },
    authenticate: true,
    resolve: {
      init: (initService) ->
        initService.cache()
    }
  })
  .state('player.home', {
    url: '/home',
    templateUrl: 'views/player-analysis-views/home.html',
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
    templateUrl: 'views/player-analysis-views/kinetic-chain/kinetic-chain.html',
    controller: 'kineticChainController as chain',
    authenticate: true
  })
  .state('player.kinetic-chain.timeline',{
    url: '/timeline',
    templateUrl: 'views/player-analysis-views/kinetic-chain/sub-views/timeline.html',
    controller: 'kineticChainController as chain',
    authenticate: true
  })
  .state('player.kinetic-chain.strength',{
    url: '/strength',
    templateUrl: 'views/player-analysis-views/kinetic-chain/sub-views/strength.html',
    controller: 'kineticStrengthController as strength',
    authenticate: true
  })
  .state('player.kinetic-chain.table',{
    url: '/table',
    templateUrl: 'views/player-analysis-views/kinetic-chain/sub-views/table.html',
    controller: 'kineticChainTableController as table',
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
    authenticate: true,
    views: {
      '': {
        templateUrl: 'views/player-analysis-views/trends/trends.html',
        controller: 'trendsController as trends',
      },
      'trendsaccordion@player.trends': {
        templateUrl: 'views/player-analysis-views/trends/trends-tmpls/trends-accordion-tmpl.html',
      },
      'checkboxes@player.trends':{
        templateUrl: 'views/player-analysis-views/trends/trends-tmpls/trends-checkbox-tmpl.html'
      }
    }
  })
  .state('player.comparison', {
    url: '/comparison',
    authenticate: true,
    controller: 'playerController as pc',
    views: {
      '': {
        templateUrl: 'views/player-analysis-views/player-comparison/player-comparison.html',
      }
    }
  })
  .state('player.comparison.overview', {
    url: '/overview',
    authenticate: true,
    views: {
      'overviewOne@player.comparison':{
        templateUrl: 'views/player-analysis-views/player-comparison/overview/overview-one.html'
      },
      'overviewTwo@player.comparison':{
        templateUrl: 'views/player-analysis-views/player-comparison/overview/overview-two.html'
      },
      'addPlayer@player.comparison': {
        templateUrl: 'views/player-analysis-views/player-comparison/add-player.html'
      }
    }
  })
  .state('player.comparison.visual', {
    url: '/visual',
    authenticate: true,
    views: {
      'visualOne@player.comparison':{
        templateUrl: 'views/player-analysis-views/player-comparison/visual/visual-one.html'
      },
      'visualTwo@player.comparison':{
        templateUrl: 'views/player-analysis-views/player-comparison/visual/visual-two.html'
      },
      'addPlayer@player.comparison': {
        templateUrl: 'views/player-analysis-views/player-comparison/add-player.html'
      }
    }
  })
  .state('player.comparison.stats', {
    url: '/stats',
    authenticate: true,
    views: {
      'statsOne@player.comparison':{
        templateUrl: 'views/player-analysis-views/player-comparison/stats/stats-one.html',
      },
      'elbowTable@player.comparison.stats': {
        templateUrl: 'views/player-analysis-views/player-comparison/stats/tables/elbow.html'
      },
      'shoulderTable@player.comparison.stats': {
        templateUrl: 'views/player-analysis-views/player-comparison/stats/tables/shoulder.html'
      },
      'trunkTable@player.comparison.stats': {
        templateUrl: 'views/player-analysis-views/player-comparison/stats/tables/trunk.html'
      },
      'hipsTable@player.comparison.stats': {
        templateUrl: 'views/player-analysis-views/player-comparison/stats/tables/hips.html'
      },
      'footTable@player.comparison.stats': {
        templateUrl: 'views/player-analysis-views/player-comparison/stats/tables/foot.html'
      },
      'addPlayer@player.comparison': {
        templateUrl: 'views/player-analysis-views/player-comparison/add-player.html'
      }
    }
  })

app.run ($rootScope, $state, $cookies, $location) ->
  $rootScope.$on "$stateChangeError", (event, toState, toParams, fromState, fromParams) ->
    debugger
    event.preventDefault();
    $state.go('error')

  $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
    
    while document.querySelectorAll(".d3-tip").length
      document.querySelectorAll(".d3-tip")[0].parentNode.removeChild(document.querySelectorAll(".d3-tip")[0]);

    #if not logged in, go to login screen
    if (toState.authenticate && !$cookies.get('motus'))
      #User isn’t authenticated
      $location.url('/#/login');
      $state.go('login')
      event.preventDefault();


_.mixin(s.exports());
require './directives/arealinechart.coffee'
require './directives/barchart.coffee'
require './directives/groupedbarchart.coffee'
require './directives/kinetic.coffee'
require './directives/linechart.coffee'
require './directives/piestats.coffee'
require './services/currentPlayerFactory.coffee'
require './services/currentUserFactory.coffee'
require './services/statService.coffee'
require './services/lastLocation.coffee'
require './controllers/indexController.coffee'
require './controllers/team-overview-controllers/teamOverviewController.coffee'
require './controllers/playerController.coffee'
require './controllers/login/loginController.coffee'
require './controllers/login/forgotPasswordController.coffee'
require './controllers/side-icon-controllers/snap-shot-controllers/ballreleaseSnapShotController.coffee'
require './controllers/side-icon-controllers/snap-shot-controllers/footcontactSnapShotController.coffee'
require './controllers/side-icon-controllers/snap-shot-controllers/maxexcursionSnapShotController.coffee'
require './controllers/side-icon-controllers/homeController.coffee'
require './controllers/side-icon-controllers/kineticChainController.coffee'
require './controllers/side-icon-controllers/kineticChainTableController.coffee'
require './controllers/side-icon-controllers/kineticStrengthController.coffee'
require './controllers/side-icon-controllers/jointKineticsController.coffee'
require './controllers/side-icon-controllers/trendsController.coffee'
require './filters/rounded.coffee'

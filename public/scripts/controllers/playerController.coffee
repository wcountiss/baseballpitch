angular.module('motus').controller('playerController',
  ['$scope', '$http', 'currentPlayerFactory', '$state', '$player'
    ($scope, $http, currentPlayerFactory, $state, $player) ->
      #log current state
      console.log 'onLoad Current State:', $state.current.name
      #Grab data from the factory service
      cpf = currentPlayerFactory
      randomNumber = (min, max) ->
        Math.floor(Math.random() * max + min)

      # Random number to generate boolean for Roster list icon colors
      colorOptions = [ '#f90b1c', '#ffaa22', '#00be76' ]
      toolTipOptions = [ 'Bad', 'Ok', 'Good' ]

      #random stats
      statNames = ['arm','throwShoulder','otherShoulder','hip','foot']
      statSlices = [10,10,9,8,6]
      _.each statNames, (stat, i) ->
        scores = [
          { order: 1, score: 100, weight: 1, label: "Rotation" }
          { order: 1, score: 100, weight: 1, label: "Movement" }
          { order: 1, score: 100, weight: 1, label: "Force" }
          { order: 1, score: 100, weight: 1, label: "Acceleration" }
          { order: 1, score: 100, weight: 1, label: "Timing" }
          { order: 1, score: 100, weight: 1, label: "Deceleration" }
          { order: 1, score: 100, weight: 1, label: "Velocity" }
          { order: 1, score: 100, weight: 1, label: "Momentum" }
          { order: 1, score: 100, weight: 1, label: "Distance" }
          { order: 1, score: 100, weight: 1, label: "Rate" }
        ]
        _.each scores, (score) ->
          randomNum = randomNumber(0,3)
          score.color = colorOptions[randomNum]
          score.tooltip = toolTipOptions[randomNum]
        #Number of slices
        score = _.slice(scores, 0, statSlices[i])
        $scope[stat] = score

      getPlayers = () ->
        $player.getPlayers()
        .then (players) ->
          console.log players
          pitches = ['right', 'left']
          position = ['starter', 'relief', 'closer']

          #loop through team and add roster booleans
          _.each (players), (player) ->
            #hardcoded stats, change to parse later
            player = _.extend(player, { age: _.random(20,40), height: _.random(65,80), weight: _.random(150,180), birthPlace: "USA", position: position[_.random(2)], level: 'mlb', pitches: pitches[_.random(1)], imgUrl: '../images/matt-harvey.png', alt: 'Matt Harvey'})

            player
          $scope.playerRoster = players
          #makes the first player in the list the selected player when the pages loads
          cpf.currentPlayer = players[0]
          $scope.currentPlayer = cpf.currentPlayer

      #Page Load
      getPlayers()
      $scope.selectedPlayer = (selected) ->
        cpf.currentPlayer = selected
        $scope.currentPlayer = cpf.currentPlayer
        myState = $state.current.name
        $state.reload(myState)



      #########################################
      # SIDE ICON LOGIC                      #
      ########################################

      #Private function to get icon state
      getCurrentState = (myState) ->
        if myState == 'player.home'
          $scope.homeSideButtonActive = true
        else
          $scope.homeSideButtonActive = false
        if myState == 'player.trends'
          $scope.trendsSideButtonActive = true
        else
          $scope.trendsSideButtonActive = false
        if myState == 'player.kinetic-chain'
          $scope.kineticSideButtonActive = true
        else
          $scope.kineticSideButtonActive = false
        if myState == 'player.ball-release'
          $scope.ballreleaseSideButtonActive = true
        else
          $scope.ballreleaseSideButtonActive = false
        if myState == 'player.foot-contact'
          $scope.footcontactSideButtonActive = true
        else
          $scope.footcontactSideButtonActive = false
        if myState == 'player.max-excursion'
          $scope.maxexcursionSideButtonActive = true
        else
          $scope.maxexcursionSideButtonActive = false
        if myState == 'player.joint-kinetics'
          $scope.jointkineticsSideButtonActive = true
        else
          $scope.jointkineticsSideButtonActive = false

      #Sets the initial value of Icons when Application Loads up
      $scope.homeSideButtonActive = getCurrentState($state.current.name)
      $scope.trendsSideButtonActive = getCurrentState($state.current.name)
      $scope.kineticSideButtonActive = getCurrentState($state.current.name)
      $scope.ballreleaseSideButtonActive = getCurrentState($state.current.name)
      $scope.footcontactSideButtonActive = getCurrentState($state.current.name)
      $scope.maxexcursionSideButtonActive = getCurrentState($state.current.name)
      $scope.jointkineticsSideButtonActive = getCurrentState($state.current.name)


      #Change the Active Icon upon button press
      # a string from the player.html is passed in and evaluated
      $scope.buttonPressed = (myState) ->
        if myState == 'player.home'
          $scope.homeSideButtonActive = true
        else
          $scope.homeSideButtonActive = false
        if myState == 'player.trends'
          $scope.trendsSideButtonActive = true
        else
          $scope.trendsSideButtonActive = false
        if myState == 'player.kinetic-chain'
          $scope.kineticSideButtonActive = true
        else
          $scope.kineticSideButtonActive = false
        if myState == 'player.ball-release'
          $scope.ballreleaseSideButtonActive = true
        else
          $scope.ballreleaseSideButtonActive = false
        if myState == 'player.foot-contact'
          $scope.footcontactSideButtonActive = true
        else
          $scope.footcontactSideButtonActive = false
        if myState == 'player.max-excursion'
          $scope.maxexcursionSideButtonActive = true
        else
          $scope.maxexcursionSideButtonActive = false
        if myState == 'player.joint-kinetics'
          $scope.jointkineticsSideButtonActive = true
        else
          $scope.jointkineticsSideButtonActive = false

  ])

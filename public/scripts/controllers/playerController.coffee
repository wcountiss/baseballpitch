angular.module('motus').controller('playerController',
['$scope', '$http'
  ($scope, $http) ->
    # Random number to generate boolean for Roster list icon colors
    randomBoolean = () ->
      !(Math.random()+.5|0)
    randomNumber = (min, max) ->
      Math.floor(Math.random() * max + min)

    colorOptions = [ '#e35746', '#ffe966', '#00a339' ]
    toolTipOptions = [ 'Bad', 'Ok', 'Good' ]

    #hardcoded change to by login later
    $scope.teamId = 1

    #random stats
    statNames = ['arm','shoulder','hip','leg','foot']
    _.each statNames, (stat) ->
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
      #random number of slices
      scores = _.slice(scores, 0, randomNumber(4,10))
      $scope[stat] = scores

    getPlayers = () ->
      $http.post("player/find",  { teamId: $scope.teamId })
      .success (players) ->
        pitches = ['right', 'left']
        position = ['starter', 'relief', 'closer']

        #loop through team and add roster booleans
        _.each (players), (player) ->
          player.longThrow = randomBoolean()
          player.bullPen = randomBoolean()
          player.base = randomBoolean()

          #hardcoded stats, change to parse later
          player = _.extend(player, { age: _.random(20,40), height: _.random(65,80), weight: _.random(150,180), birthPlace: "USA", position: position[_.random(2)], level: 'mlb', pitches: pitches[_.random(1)], imgUrl: '../images/matt-harvey.png', alt: 'Matt Harvey'})

          player
        $scope.playerRoster = players
        #makes the first player in the list the selected player when the pages loads
        $scope.currentPlayer = players[0]

    #Page Load
    getPlayers()

    $scope.selectedPlayer = (selected) ->
      console.log "clicked"
      $scope.currentPlayer = selected
])

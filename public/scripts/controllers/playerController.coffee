angular.module('motus').controller('playerController',

  ['$http', 'currentPlayerFactory','eliteFactory','$state', '$player','$stat','$q','$pitch'
    ($http, currentPlayerFactory, eliteFactory, $state, $player, $stat, $q, $pitch) ->

      pc = this
      pc.state = $state
      #log current state
      console.log 'onLoad Current State:', $state.current.name
      #Grab data from the factory service
      cpf = currentPlayerFactory
      ef = eliteFactory
      console.log('ELITE FACTORY:',ef)

      loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
      $q.all(loadPromises).then (results) ->
        pc.currentPlayer = results[1]
        console.log('THIS PLAYER: ',results[1]) 
        console.log('THIS PLAYER NAME: ',pc.currentPlayer.athleteProfile.firstName) 
        $stat.runStatsEngine(pc.currentPlayer.pitches).then (stats) ->
          console.log('DOUBLECHECK PLAYERNAME:', pc.currentPlayer.athleteProfile.firstName)
          console.log('THIS PLAYER STATS:',stats)
      randomNumber = (min, max) ->
        Math.floor(Math.random() * max + min)

      # Random number to generate boolean for Roster list icon colors
      colorOptions = [ '#f90b1c', '#ffaa22', '#00be76' ]
      toolTipOptions = [ 'Bad', 'Ok', 'Good' ]

      # random stats
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
        pc[stat] = score

      getPlayers = () ->
        return $player.getPlayers()
        .then (players) ->
          position = ['starter', 'relief', 'closer']

          #loop through team and add roster booleans
          _.each (players), (player) ->
            #hardcoded stats, change to parse later
            player = _.extend(player, { age: _.random(20,40), height: _.random(65,80), weight: _.random(150,180), birthPlace: "USA", position: position[_.random(2)], level: 'mlb', imgUrl: '../images/matt-harvey.png', alt: 'Matt Harvey'})
            player
          pc.playerRoster = players
         
      loadChart = () ->
         #Get pitches a year back
        $pitch.getPitches({ daysBack: 365 })
        .then (pitches) ->
          pitches = _.filter pitches, (pitch) -> pitch.athleteProfile.objectId == pc.currentPlayer.athleteProfile.objectId
          #group pitches by month
          pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/01/YYYY')
          #run engine through all pitches per month
          statsPromises = []
          _.each _.keys(pitches), (key) -> statsPromises.push $stat.runStatsEngine(pitches[key])
          $q.all(statsPromises)
          .then (stats) ->
            #map overall score per month
            scores = _.map _.keys(pitches), (key, i) -> return { date: moment(key, "MM/DD/YYYY").startOf('month').format('MM/YYYY'), score: stats[i].overallScore.ratingScore}
            pc.playerScores = scores

      #Page Load
      getPlayers()
      .then () ->
        loadChart()


      #Select Current Player
      pc.selectedPlayer = (selected) ->
        cpf.currentPlayer = selected
        pc.currentPlayer = cpf.currentPlayer
        loadChart()
        myState = $state.current.name
        $state.reload(myState)

      return pc
  ])

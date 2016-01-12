angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$q', '$player', '$stat'
    ($http, $state, $q, $player, $stat) ->
      team = this

      $http.post("pitch", { daysBack: 365 })
      .success (pitches) ->
        #group pitches by month
        pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/01/YYYY')
        #run engine through all pitches per month
        statsPromises = []
        _.each _.keys(pitches), (key) -> statsPromises.push $stat.runStatsEngine(pitches[key])
        $q.all(statsPromises)
        .then (stats) ->
          #map overall score per month
          scores = _.map _.keys(pitches), (key, i) -> return { date: moment(key, "MM/DD/YYYY").startOf('month').format('MM/YYYY'), score: stats[i].overallScore.ratingScore}
          #Look back 12 months and fill in where no data
          if scores.length < 12
            for month in [1..12]
              lastMonthsScore = _.find scores, (score) -> score.date == moment().add(-month, 'M')
              if !lastMonthsScore 
                scores.push { date: moment().add(-month,'M').format('MM/YYYY'), score: 0, filler: true }          
          team.teamScores = scores

      team.myteam = $player.getPlayers()
      .then (players) ->
        team.bullpen = players
         
        $stat.getPlayerAwards(players)
        .then () ->
          _.each players, (player) ->
            team.judgement = {}

            if player.stats.award == "Best Performer"
             team.judgement.fname = player.athleteProfile.firstName
             team.judgement.lname = player.athleteProfile.lastName
             team.judgement.awardtitle = "Best"
             team.judgement.awardsub = "Performer"
             team.sixPlayers.push(team.judgement)

            if player.stats.award == "Worst Performer"
             team.judgement.fname = player.athleteProfile.firstName
             team.judgement.lname = player.athleteProfile.lastName
             team.judgement.awardtitle = "Worst"
             team.judgement.awardsub = "Performer"
             team.sixPlayers.push(team.judgement)

            if player.stats.award == "Improved"
             team.judgement.fname = player.athleteProfile.firstName
             team.judgement.lname = player.athleteProfile.lastName
             team.judgement.awardtitle = "Improved"
             team.judgement.awardsub = "Most Since Last Month"
             team.sixPlayers.push(team.judgement) 

            if player.stats.award == "Regressed"
             team.judgement.fname = player.athleteProfile.firstName
             team.judgement.lname = player.athleteProfile.lastName
             team.judgement.awardtitle = "Regressed"
             team.judgement.awardsub = "Most Since Last Month"
             team.sixPlayers.push(team.judgement)

            if player.stats.award == "Best Accuracy"
             team.judgement.fname = player.athleteProfile.firstName
             team.judgement.lname = player.athleteProfile.lastName
             team.judgement.awardtitle = "Best"
             team.judgement.awardsub = "Accuracy"
             team.sixPlayers.push(team.judgement)

            if player.stats.award == "Fastest Pitch" 
             team.judgement.fname = player.athleteProfile.firstName
             team.judgement.lname = player.athleteProfile.lastName
             team.judgement.awardtitle = "Fastest"
             team.judgement.awardsub = "Pitch"
             team.sixPlayers.push(team.judgement)
            console.log 'sixPlayers: ',team.sixPlayers
            i = 6 - team.sixPlayers.length
            _.times i, (n) ->
              team.judgement = {}
              team.judgement.fname = "NA"
              team.judgement.awardtitle = "NO DATA"
              team.judgement.awardsub = "No Data Available"
              team.sixPlayers.push(team.judgement)
            _.each team.sixPlayers, (player,i) ->
    
      #Judgement Array
      team.sixPlayers = []
      # team.test = ["amit", "bob","cara","peter","quin","robby"]
      return team
  ])

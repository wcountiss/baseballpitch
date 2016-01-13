angular.module('motus').controller('teamOverviewController',
  ['$http', '$state', '$q', '$player', '$pitch', '$stat'
    ($http, $state, $q, $player, $pitch, $stat) ->
      team = this

      $pitch.getPitches({ daysBack: 365 })
      .then (pitches) ->
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
          judgements = [
            {award: 'Best Performer', title: 'Best', subtitle: 'Performer'},
            {award: 'Worst Performer', title: 'Worst', subtitle: 'Performer'},
            {award: 'Improved', title: 'Improved', subtitle: 'Most Since Last Month'},
            {award: 'Regressed', title: 'Regressed', subtitle: 'Most Since Last Month'},
            {award: 'Best Accuracy', title: 'Best', subtitle: 'Accuracy'},
            {award: 'Fastest Pitch', title: 'Fast', subtitle: 'Pitch'}
          ]

          _.each judgements, (judgement) ->
            team.judgement = {}
            
            player = _.find(players, (player) -> player.stats.award == judgement.award)
            if player
              team.judgement.fname = player.athleteProfile.firstName
              team.judgement.lname = player.athleteProfile.lastName
              team.judgement.awardtitle = judgement.title
              team.judgement.awardsub = judgement.subtitle
              team.sixPlayers.push(team.judgement)
              
            i = 6 - team.sixPlayers.length
            _.times i, (n) ->
              team.judgement = {}
              team.judgement.fname = "NA"
              team.judgement.awardtitle = "NO DATA"
              team.judgement.awardsub = "No Data Available"
              team.sixPlayers.push(team.judgement)
    
      #Judgement Array
      team.sixPlayers = []
      # team.test = ["amit", "bob","cara","peter","quin","robby"]
      return team
  ])

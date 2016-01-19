'use strict'
angular.module('d3').directive 'arealinechart', [
  'd3'
  '$window'
  (d3, $window) ->
    {
      restrict: 'E'
      scope:
        width: '@'
        height: '@'
        windowWidth: '@'
        text: '@'
        fontFamily: '@'
        fontSize: '@'
        bind: '&'
        onClick: '&'
        onHover: '&'
      link: (scope, element, attrs) ->

        updateChart = ->
          width = 960
          height = 500
          if angular.isDefined(attrs.width)
            if attrs.width.indexOf('%') > -1
              width = attrs.width.split('%')[0] / 100 * $window.innerWidth
            else
              width = attrs.width
          if angular.isDefined(attrs.height)
            height = attrs.height
          margin = 
            top: 20
            right: 20
            bottom: 30
            left: 50
          width = width - (margin.left) - (margin.right)
          height = height - (margin.top) - (margin.bottom)
          parseDate = d3.time.format('%m/%Y').parse
          x = d3.time.scale().range([
            0
            width
          ])
          y = d3.scale.linear().range([
            height
            0
          ])
          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++
          svg = d3.select(element[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
          if angular.isDefined(scope.bind())
            bindData = scope.bind()
            #Look back 12 months and fill in where no data
            if bindData.length < 12
              month = 1
              while month <= 12
                lastMonthsScore = _.find(bindData, (score) ->
                  score.date == moment().add(-month, 'M')
                )
                if !lastMonthsScore
                  bindData.push
                    date: moment().add(-month, 'M').format('MM/YYYY')
                    score: 0
                    filler: true
                month++
            data = _.cloneDeep(bindData)
            data.forEach (d) ->
              d.date = parseDate(d.date)
              d.score = +d.score
              return
            # set axis
            xAxis = d3.svg.axis().scale(x).orient('bottom').ticks(data.length).tickFormat(d3.time.format('%b'))
            yAxis = d3.svg.axis().scale(y).orient('left')
            x.domain d3.extent(data, (d) ->
              d.date
            )
            y.domain [
              0
              100
            ]
            # area fill
            area = d3.svg.area().x((d) ->
              x d.date
            ).y0(height).y1((d) ->
              y d.score
            )
            svg.append('path').datum(data).attr('class', 'area').attr 'd', area
            # create border line on top
            lineFunction = d3.svg.line().x((d) ->
              x d.date
            ).y((d) ->
              y d.score
            ).interpolate('linear')
            svg.append('path').datum(data).attr('class', 'line').attr('stroke-width', '.5em').attr('stroke', 'black').attr 'd', lineFunction
            # background lines
            data.forEach (d) ->
              svg.append('line').datum(d).attr('x1', (d) ->
                x d.date
              ).attr('y1', (d) ->
                y 0
              ).attr('x2', (d) ->
                x d.date
              ).attr('y2', (d) ->
                y 100
              ).attr('class', 'background-lines').attr('stroke-width', 1).attr('stroke', 'grey').style 'opacity', '0.5'
              return
            [
              0
              20
              40
              60
              80
              100
            ].forEach (everyFew) ->
              svg.append('line').attr('x1', d3.min(data, (d) ->
                x d.date
              )).attr('y1', (d) ->
                y everyFew
              ).attr('x2', d3.max(data, (d) ->
                x d.date
              )).attr('y2', (d) ->
                y everyFew
              ).attr('class', 'background-lines').attr('stroke-width', 1).attr('stroke', 'grey').style 'opacity', '0.5'
              return
            
            # elite data
            svg.append('line').attr('x1', 0).attr('y1', ->
              y 66
            ).attr('x2', d3.max(data, (d) ->
              x d.date
            )).attr('y2', ->
              y 66
            ).attr('class', 'average').attr('stroke-width', 2).attr 'stroke', 'black'
            
            #circles along linear
            data.forEach (d) ->
              svg.append('circle').datum(d).attr('r', 2).attr('cx', (d) ->
                x d.date
              ).attr('cy', (d) ->
                y d.score
              ).attr('class', (d) ->
                if d.filler
                  'circle filler'
                else
                  'circle'
              ).attr('fill', 'black').attr 'stroke', 'black'
              return
            
            svg.append('g').attr('class', 'x-axis').attr('transform', 'translate(0,' + height + ')').call xAxis
            svg.append('g').attr('class', 'y-axis').call(yAxis).append('text').attr('transform', 'rotate(-90)').attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end').text scope.text
          return

        scope.$watch 'bind()', (->
          updateChart()
          return
        ), false
        
        angular.element($window).bind 'resize', ->
          updateChart()
          return
        return

    }
]
'use strict'
angular.module('d3').directive 'linechart', [
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
          x = d3.scale.linear().range([0,width])
          y = d3.scale.linear().range([height,0])
          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++
 
          svg = d3.select(element[0])
          .append('svg')
          .attr('width', width + margin.left + margin.right)
          .attr('height', height + margin.top + margin.bottom).append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
          if angular.isDefined(scope.bind())
            bindData = scope.bind()            
            data = _.cloneDeep(bindData)
            
            data.scores.forEach (d) ->
              d.index = d.index
              d.score = +d.score

            # set axis
            xAxis = d3.svg.axis().scale(x).orient('bottom')
            yAxis = d3.svg.axis().scale(y).orient('left')
            x.domain [1, data.scores.length]
            ymin = d3.min(data.scores, (d) -> d.score)
            if data.average < ymin
              ymin = data.average
            ymax = d3.max(data.scores, (d) -> d.score)
            if data.average > ymax
              ymax = data.average
            y.domain [ymin, ymax]
            
            # create line
            lineFunction = d3.svg.line()
            .x((d) -> x(d.index))
            .y((d) -> y(d.score))
            .interpolate('linear')
            
            svg.append('path')
            .datum(data.scores)
            .attr('class', 'line')
            .attr('stroke-width', '.5em')
            .attr('stroke', 'black')
            .attr('d', lineFunction)
            
            # elite data
            svg.append('line').attr('x1', 0)
            .attr('y1', (d) -> y(data.average))
            .attr('x2', d3.max(data.scores, (d) -> x d.index)) 
            .attr('y2', -> y(data.average))
            .attr('class', 'average')
            .attr('stroke-width', 2)
            .attr 'stroke', 'black'
            
            #circles along linear
            data.scores.forEach (d) ->
              svg.append('circle')
              .datum(d).attr('r', 2).attr('cx', (d) ->
                x d.index
              ).attr('cy', (d) ->
                y d.score
              ).attr('class', 'circle')
              .attr('fill', 'black')
              .attr 'stroke', 'black'
            
            svg.append('g').attr('class', 'x-axis').attr('transform', 'translate(0,' + height + ')').call xAxis
            svg.append('g').attr('class', 'y-axis').call(yAxis).append('text').attr('transform', 'rotate(-90)').attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end').text scope.text

        scope.$watch 'bind()', (-> updateChart()), false
        angular.element($window).bind 'resize', -> updateChart()
    }
]
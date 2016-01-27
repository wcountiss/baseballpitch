'use strict'
angular.module('d3').directive 'kinetic', [
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
            top: 25
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
          .append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          if angular.isDefined(scope.bind())
            bindData = scope.bind()            
            data = _.cloneDeep(bindData)

            color = d3.scale.category10();

            xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom")
            # .tick(data.length)

            yAxis = d3.svg.axis()
            .scale(y)
            .orient("left")

            lineFunction = d3.svg.line()
            .interpolate("basis")
            .x((d) -> return x(d.index))
            .y((d) -> return y(d.score));

            color.domain(_.pluck(data, 'key'))

            lines = data.map((d) -> 
              return {
                key: d.key,
                values: d.scores.map((d, i) ->
                  return {index: i, score: +d}
                )
              })

            x.domain([
              d3.min(_.pluck(_.flatten(_.pluck(lines, 'values')),'index')),
              d3.max(_.pluck(_.flatten(_.pluck(lines, 'values')),'index'))
            ])

            y.domain([
              d3.min(_.pluck(_.flatten(_.pluck(lines, 'values')),'score')),
              d3.max(_.pluck(_.flatten(_.pluck(lines, 'values')),'score'))
            ])

            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis)

            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", 6)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text("UNITS")

            line = svg.selectAll(".line")
                .data(lines)
              .enter().append("g")
                .attr("class", "line")

            line.append("path")
                .attr("class", "line")
                .attr("d", (d) -> return lineFunction(d.values))
                .style("stroke", (d) -> return color(d.key))

        scope.$watch 'bind()', (-> updateChart()), false
        angular.element($window).bind 'resize', -> updateChart()
    }
]
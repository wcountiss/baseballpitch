'use strict'
angular.module('d3').directive 'barchart', [
  'd3'
  '$window'
  (d3, $window) ->
    {
      restrict: 'E'
      scope:
        width: '@'
        height: '@'
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

          x = d3.scale.ordinal()
              .rangeRoundBands([0, width], .1);

          y = d3.scale.linear()
              .range([height, 0]);

          xAxis = d3.svg.axis()
              .scale(x)
              .orient("bottom");

          yAxis = d3.svg.axis()
              .scale(y)
              .orient("left")

          #tooltip
          tip = d3.tip()
            .attr('class', 'd3-tip')
            .offset([-10, 0])
            .html (d) ->
              return "<span style='color:red'>" + parseFloat(d.value).toFixed(1) + " Degrees/Second</span>";

          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++

          svg = d3.select(element[0]).append('svg')
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
            .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          
          #add tooltip
          svg.call(tip);

          if angular.isDefined(scope.bind())
            bindData = scope.bind()
            data = _.cloneDeep(bindData)

           #set yxis to 0 or min - 1 if under 0 to whichever is higher max value or average 
            maxValue = d3.max(data, (d) -> d.value)
            maxAverage = d3.max(data, (d) -> d.average)
            if maxValue > maxAverage then ymax = maxValue else ymax = maxAverage
            
            x.domain(data.map((d) -> d.bar ))
            y.domain [0, ymax]

            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis)

            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", "-4.5em")
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text("Degrees/Second")

            #background lines
            svg.append("g")      
            .attr("class", "grid")
            .call(yAxis
              .tickSize(-width, 0, 0)
              .tickFormat("")
            ) 

            svg.selectAll(".bar")
                .data(data)
              .enter()
                .append("rect")
                .attr("class", "bar")
                .attr("x", (d) -> x(d.bar))
                .attr("width", x.rangeBand())
                .attr("y", (d) -> y(d.value))
                .attr("height", (d) -> height - y(d.value))
                .attr('fill', (d) -> d.color)
                .on('mouseover', tip.show)
                .on('mouseout', tip.hide)

            #average lines
            svg.selectAll(".average")
                .data(data)
              .enter()
                .append("line")
                .attr('x1', (d) -> x(d.bar))
                .attr('x2', (d) -> x(d.bar) + x.rangeBand())
                .attr('y1', (d) -> y(d.average))
                .attr('y2', (d) -> y(d.average))
                .attr('class', 'average')
                .attr('stroke-width', 2)
                .attr('stroke', 'black')

            svg.selectAll(".average-text")
              .data(data)
             .enter()
              .append("text")
              .attr("y", (d) -> y(d.average)-5)
              .attr("x", (d) -> x(d.bar) + x.rangeBand())
              .attr("dy", ".3em")
              .style("text-anchor", "end")
              .attr('class', 'average average-text')
              .text("MLB average")


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
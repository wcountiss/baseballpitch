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
          .append('svg')
          .attr('width', width + margin.left + margin.right)
          .attr('height', height + margin.top + margin.bottom).append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
          
          if scope.bind()
            bindData = scope.bind()            
            data = _.cloneDeep(bindData)
            
            #absolute type of metric
            if data.yType == 1
              data.average = Math.abs(data.average)
              _.each data.scores, (score) ->
                score.score = Math.abs(score.score)

            #tool tip
            tip = d3.tip()
            .attr('class', 'd3-tip')
            .html((d) ->
              '<div class="d3-tip-heading">' + _.humanize(data.heading) + '</div><div class="d3-tip-tooltip">' + parseFloat(d.score).toFixed(0) + ' ' + data.units + '</div><div class="d3-tip-label">' + _.humanize(d.name) + '</div>'
            )
            svg.call tip

            if data.scores?.length
              data.scores.forEach (d) ->
                d.index = d.index
                d.score = +d.score

              # set axis
              xAxis = d3.svg.axis().scale(x).orient('bottom').tickFormat(d3.format("d"))
              yAxis = d3.svg.axis().scale(y).orient('left')
              x.domain [1, data.scores.length]
              ymin = d3.min(data.scores, (d) -> d.score)
              if data.average < ymin
                ymin = data.average
              ymax = d3.max(data.scores, (d) -> d.score)
              if data.average > ymax
                ymax = data.average

              #if passed in
              if data.yMin?
                ymin = data.yMin
              if data.yMax?
                ymax = data.yMax

               y.domain [ymin, ymax]
            
              #background lines
              svg.append("g")      
              .attr("class", "grid")
              .call(d3.svg.axis().scale(y).orient('left')
                .tickSize(-width, 0, 0)
                .tickFormat("")
              )

              bisectIndex = d3.bisector((d) -> return d.index;).left
              mousemove = () ->
                x0 = x.invert(d3.mouse(this)[0])
                i = bisectIndex(data.scores, x0, 1)
                d0 = data.scores[i - 1]
                d1 = data.scores[i]
                d = if x0 - d0.index > d1.index - x0 then d1 else d0
                
                d3.selectAll(".selector").remove();
                
                svg.append('line')
                .attr('x1', x(d.index))
                .attr('y1', 0)
                .attr('x2', x(d.index) )
                .attr('y2', height)
                .attr('class', 'selector')
                .attr('stroke-width', 2)
                .attr('stroke', 'black')

                tip.show(d)
                .style("top", (event.pageY-50)+"px")
                .style("left",(event.pageX-40)+"px")

              # create line
              lineFunction = d3.svg.line()
              .x((d) -> x(d.index))
              .y((d) -> 
                if d.score > ymax
                  return ymax
                if d.score < ymin
                  return ymin
                return y(d.score)
              )
              .interpolate('monotone')
              
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
              .attr('stroke', 'black')
              
              #rect to capture mouse
              svg.append("rect")
              .attr("width", width)
              .attr("height", height)
              .style("fill", "none")
              .style("pointer-events", "all") 
              .on("mouseout", (d) -> tip.hide())
              .on("mousemove", mousemove)

              svg.append('g').attr('class', 'x axis').attr('transform', 'translate(0,' + height + ')').call xAxis
              svg.append('g').attr('class', 'y axis').call(yAxis).append('text').attr('transform', 'rotate(-90)').attr('y', 6).attr('dy', '-4.3em').style('text-anchor', 'end').text data.units

        scope.$watch 'bind()', (-> updateChart()), false
        angular.element($window).bind 'resize', -> updateChart()
    }
]
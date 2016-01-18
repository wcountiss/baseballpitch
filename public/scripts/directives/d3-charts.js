'use strict';
angular.module('d3').directive('piestats', [
  'd3',
  function (d3) {
    return {
      restrict: 'E',
      scope: {
        width: '@',
        height: '@',
        fontFamily: '@',
        fontSize: '@',
        slices: '@',
        bind: '&',
        onClick: '&',
        onHover: '&'
      },
      link: function (scope, element, attrs) {
        
        var updateChart = function() {
          var width = 100,
              height = 100,
              scale = 1,
              radius = Math.min(width, height) / 2,
              innerRadius = 0.2 * radius;

          if (angular.isDefined(attrs.width))
            width = attrs.width;
          if (angular.isDefined(attrs.height))
            height = attrs.height;

          var tip = d3.tip()
            .attr('class', 'd3-tip')
            .html(function(d) { return '<div class="d3-tip-tooltip">' + d.data.tooltip + '</div><div class="d3-tip-label">' + d.data.label + '</div>'; })

          var pie = d3.layout.pie()
              .sort(null)
              .value(function(d) { return d.width; });

          var arc = d3.svg.arc()
            .innerRadius(innerRadius)
            .outerRadius(function (d) { 
              return (radius - innerRadius) * (d.data.score / 100.0) + innerRadius; 
            });

          // remove the last version and recreate 
          var elementChildren = element[0].children;
          for (var i = 0; i < elementChildren.length; i++) {
            element[0].removeChild(elementChildren[i])
          }

          var svg = d3.select(element[0]).append("svg")
              .attr("width", width)
              .attr("height", height)
              .append("g")
              .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

          svg.call(tip)

          if (angular.isDefined(scope.bind())) {
            var slices = scope.bind().length;            

            // Pass in number of slices
            if (angular.isDefined(attrs.slices)){
              slices = +attrs.slices;
            }

            var data = scope.bind()

            // add empty slices
            var numberOfSlices = data.length
            for (var i = 0; i < (slices-numberOfSlices); i++) {
              data.push({ "order": 0, "weight": 1, "score": 100, "label": "", "opacity": 0 });
            };
            
            data.forEach(function(d) {
              d.order  = +d.order;
              d.color  =  d.color;
              d.weight = +d.weight;
              d.score  = +d.score;
              d.width  = +d.weight;
              d.label  =  d.label;
            });
            
            var path = svg.selectAll(".solidArc")
              .data(pie(data))
              .enter()
              .append("path")
                .attr("fill", function(d) { return d.data.color; })
                .attr("class", "solidArc")
                .style("opacity", function(d){ return d.data.opacity })          
                .attr("d", arc)
                .on('mouseover', function(d) { 
                  // do not show tip if there is no slice
                  if (d.data.opacity != 0) { 
                    tip.show(d)
                  } 
                })
                .on('mouseout', tip.hide);
            
            svg.append("circle")
             .attr("class", "circle")
             .attr("fill", "white")
             .attr("cx", 0)
             .attr("cy", 0)
             .attr("r", 7);
          }
        }
        scope.$watch("bind()", function(){ updateChart() }, false);
      }
    };
  }
]);
'use strict';
angular.module('d3').directive('arealinechart', [
  'd3', '$window',
  function (d3, $window) {
    return {
      restrict: 'E',
      scope: {
        width: '@',
        height: '@',
        windowWidth: '@',
        text: '@',
        fontFamily: '@',
        fontSize: '@',
        bind: '&',
        onClick: '&',
        onHover: '&'
      },
      link: function (scope, element, attrs) {
        var updateChart = function() {
          var width = 960
          var height = 500
          if (angular.isDefined(attrs.width))
            if (attrs.width.indexOf('%') > -1){
              width = (attrs.width.split('%')[0]/100)*$window.innerWidth
            } else{
              width = attrs.width;
            }
          if (angular.isDefined(attrs.height))
            height = attrs.height;
          
          var margin = {top: 20, right: 20, bottom: 30, left: 50}
          width = width - margin.left - margin.right,
          height = height - margin.top - margin.bottom;          

          var parseDate = d3.time.format("%m/%Y").parse;

          var x = d3.time.scale()
              .range([0, width]);

          var y = d3.scale.linear()
              .range([height, 0]);

          // remove the last version and recreate 
          var elementChildren = element[0].children;
          for (var i = 0; i < elementChildren.length; i++) {
            element[0].removeChild(elementChildren[i])
          }
          var svg = d3.select(element[0]).append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          if (angular.isDefined(scope.bind())) {
            var bindData = scope.bind()

            //Look back 12 months and fill in where no data
            if (bindData.length < 12) {
              for (var month = 1; month <= 12; month++) {
                var lastMonthsScore = _.find(bindData, function (score) { 
                  return score.date == moment().add(-month, 'M')
                })
                if (!lastMonthsScore) {
                  bindData.push({ date: moment().add(-month,'M').format('MM/YYYY'), score: 0, filler: true })
                }   
              }       
            }

            var data = _.cloneDeep(bindData);
            data.forEach(function(d) {
              d.date = parseDate(d.date);
              d.score = +d.score;
            });

            // set axis
            var xAxis = d3.svg.axis()
              .scale(x)
              .orient("bottom")
              .ticks(data.length)
              .tickFormat(d3.time.format("%b"));

            var yAxis = d3.svg.axis()
                .scale(y)
                .orient("left");
            x.domain(d3.extent(data, function(d) { return d.date; }));
            y.domain([0, 100]);

            // area fill
            var area = d3.svg.area()
              .x(function(d) { return x(d.date); })
              .y0(height)
              .y1(function(d) { return y(d.score); });
            svg.append("path")
                .datum(data)
                .attr("class", "area")
                .attr("d", area);

            // create border line on top
            var lineFunction = d3.svg.line()
              .x(function(d) { return x(d.date); })
              .y(function(d) { return y(d.score); })
              .interpolate("linear");
            svg.append("path")
                .datum(data)
                .attr("class", "line")
                .attr("stroke-width", ".5em")
                .attr("stroke", "black")
                .attr("d", lineFunction);

            // background lines
            data.forEach(function(d) {
              svg.append("line")
                .datum(d)
                .attr("x1", function(d){ return x(d.date);})
                .attr("y1", function(d){ return y(0);})
                .attr("x2", function(d){ return x(d.date);})
                .attr("y2", function(d){ return y(100);})
                .attr("class", "background-lines")
                .attr("stroke-width", 1)
                .attr("stroke", "grey")
                .style("opacity", "0.5");
            });
            [0,20,40,60,80,100].forEach(function(everyFew) {
              svg.append("line")
                .attr("x1", d3.min(data, function(d) { return x(d.date); }))
                .attr("y1", function(d){ return y(everyFew);})
                .attr("x2", d3.max(data, function(d) { return x(d.date); }))
                .attr("y2", function(d){ return y(everyFew);})
                .attr("class", "background-lines")
                .attr("stroke-width", 1)
                .attr("stroke", "grey")
                .style("opacity", "0.5");
            });

            // elite data
            svg.append("line")
              .attr("x1", 0)
              .attr("y1", function(){ return y(66);})
              .attr("x2", d3.max(data, function(d) { return x(d.date); }))
              .attr("y2", function(){ return y(66);})
              .attr("class", "average")
              .attr("stroke-width", 2)
              .attr("stroke", "black")
            
            //circles along linear
            data.forEach(function(d) {
              svg.append("circle")
                .datum(d)
                .attr("r", 2)
                .attr("cx", function(d){ return x(d.date);})
                .attr("cy", function(d){ return y(d.score);})
                .attr("class", function(d){ if(d.filler) { return "circle filler" } else return "circle" })
                .attr("fill", "black")
                .attr("stroke", "black")
            });


            svg.append("g")
                .attr("class", "x-axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis);

            svg.append("g")
                .attr("class", "y-axis")
                .call(yAxis)
              .append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", 6)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text(scope.text);
          }
        }
        scope.$watch("bind()", function(){ updateChart() }, false);
        angular.element($window).bind('resize', function(){ updateChart()});
      }
    };
  }
]);
'use strict';
angular.module('d3').directive('groupedbarchart', [
  'd3', '$window',
  function (d3, $window) {
    return {
      restrict: 'E',
      scope: {
        width: '@',
        height: '@',
        windowWidth: '@',
        text: '@',
        fontFamily: '@',
        fontSize: '@',
        bind: '&',
        onClick: '&',
        onHover: '&'
      },
      link: function (scope, element, attrs) {
        var updateChart = function() {
          var width = 960
          var height = 500
          if (angular.isDefined(attrs.width))
            if (attrs.width.indexOf('%') > -1){
              width = (attrs.width.split('%')[0]/100)*$window.innerWidth
            } else{
              width = attrs.width;
            }
          if (angular.isDefined(attrs.height))
            height = attrs.height;
          
          var margin = {top: 20, right: 20, bottom: 30, left: 50}
          width = width - margin.left - margin.right,
          height = height - margin.top - margin.bottom;

          var x0 = d3.scale.ordinal()
              .rangeRoundBands([0, width], .1);

          var x1 = d3.scale.ordinal();

          var y = d3.scale.linear()
              .range([height, 0]);

          var color = d3.scale.ordinal()
              .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

          var xAxis = d3.svg.axis()
              .scale(x0)
              .orient("bottom");

          var yAxis = d3.svg.axis()
              .scale(y)
              .orient("left")
              .tickFormat(d3.format(".2s"));

          // remove the last version and recreate 
          var elementChildren = element[0].children;
          for (var i = 0; i < elementChildren.length; i++) {
            element[0].removeChild(elementChildren[i])
          }

          var svg = d3.select(element[0]).append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          if (angular.isDefined(scope.bind())) {
            var bindData = scope.bind()

            var data = _.cloneDeep(bindData);

            // var ageNames = d3.keys(data[0]).filter(function(key) { return key !== "State"; });
            // data = data.slice(1)

            data.groups.forEach(function(d) {
              d.groupData = data.keys.map(function(key) { 
                var value = 0
                if (d[key])
                  value = +d[key]
                return { 
                  name: key, 
                  value: value
                }; 
              });
            });

            x0.domain(data.groups.map(function(d) { return d.date; }));
            x1.domain(data.keys).rangeRoundBands([0, x0.rangeBand()]);
            y.domain([d3.min(data.groups, function(d) { return d3.min(d.groupData, function(d) { return d.value; }); }), d3.max(data.groups, function(d) { return d3.max(d.groupData, function(d) { return d.value; }); })]);

            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis);

            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", 6)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text(data.units);

            var date = svg.selectAll(".date")
                .data(data.groups)
              .enter().append("g")
                .attr("class", "date")
                .attr("transform", function(d) { return "translate(" + x0(d.date) + ",0)"; });

            date.selectAll("rect")
              .data(function(d) { return d.groupData; })
              .enter().append("rect")
                .attr("width", x1.rangeBand())
                .attr("x", function(d) { return x1(d.name); })
                .attr("y", function(d) { return y(d.value); })
                .attr("height", function(d) { return height - y(d.value); })
                .style("fill", function(d) { return color(d.name); });
          }
        }
        scope.$watch("bind()", function(){ updateChart() }, false);
        angular.element($window).bind('resize', function(){ updateChart()});
      }
    };
  }
]);







'use strict';
angular.module('d3').config([
  '$provide',
  function ($provide) {
    var d3HorizonChartDecorator = function ($delegate) {
      var d3 = $delegate;
      (function () {
        d3.horizon = function () {
          var bands = 1, mode = 'offset', interpolate = 'linear', x = d3_horizonX, y = d3_horizonY, w = 960, h = 40, duration = 0;
          var color = d3.scale.linear().domain([
              -1,
              0,
              1
            ]).range([
              '#d62728',
              '#fff',
              '#1f77b4'
            ]);
          function horizon(g) {
            g.each(function (d) {
              var g = d3.select(this), xMin = Infinity, xMax = -Infinity, yMax = -Infinity, x0, y0, t0, id;
              var data = d.map(function (d, i) {
                  var xv = x.call(this, d, i), yv = y.call(this, d, i);
                  if (xv < xMin)
                    xMin = xv;
                  if (xv > xMax)
                    xMax = xv;
                  if (-yv > yMax)
                    yMax = -yv;
                  if (yv > yMax)
                    yMax = yv;
                  return [
                    xv,
                    yv
                  ];
                });
              var x1 = d3.scale.linear().domain([
                  xMin,
                  xMax
                ]).range([
                  0,
                  w
                ]), y1 = d3.scale.linear().domain([
                  0,
                  yMax
                ]).range([
                  0,
                  h * bands
                ]), t1 = d3_horizonTransform(bands, h, mode);
              if (this.__chart__) {
                x0 = this.__chart__.x;
                y0 = this.__chart__.y;
                t0 = this.__chart__.t;
                id = this.__chart__.id;
              } else {
                x0 = x1.copy();
                y0 = y1.copy();
                t0 = t1;
                id = ++d3_horizonId;
              }
              var defs = g.selectAll('defs').data([null]);
              defs.enter().append('defs').append('clipPath').attr('id', 'd3_horizon_clip' + id).append('rect').attr('width', w).attr('height', h);
              defs.select('rect').transition().duration(duration).attr('width', w).attr('height', h);
              g.selectAll('g').data([null]).enter().append('g').attr('clip-path', 'url(#d3_horizon_clip' + id + ')');
              var path = g.select('g').selectAll('path').data(d3.range(-1, -bands - 1, -1).concat(d3.range(1, bands + 1)), Number);
              var d0 = d3_horizonArea.interpolate(interpolate).x(function (d) {
                  return x0(d[0]);
                }).y0(h * bands).y1(function (d) {
                  return h * bands - y0(d[1]);
                })(data);
              var d1 = d3_horizonArea.x(function (d) {
                  return x1(d[0]);
                }).y1(function (d) {
                  return h * bands - y1(d[1]);
                })(data);
              path.enter().append('path').style('fill', color).attr('transform', t0).attr('d', d0);
              path.transition().duration(duration).style('fill', color).attr('transform', t1).attr('d', d1);
              path.exit().transition().duration(duration).attr('transform', t1).attr('d', d1).remove();
              this.__chart__ = {
                x: x1,
                y: y1,
                t: t1,
                id: id
              };
            });
            d3.timer.flush();
          }
          horizon.duration = function (x) {
            if (!arguments.length)
              return duration;
            duration = +x;
            return horizon;
          };
          horizon.bands = function (x) {
            if (!arguments.length)
              return bands;
            bands = +x;
            color.domain([
              -bands,
              0,
              bands
            ]);
            return horizon;
          };
          horizon.mode = function (x) {
            if (!arguments.length)
              return mode;
            mode = x + '';
            return horizon;
          };
          horizon.colors = function (x) {
            if (!arguments.length)
              return color.range();
            color.range(x);
            return horizon;
          };
          horizon.interpolate = function (x) {
            if (!arguments.length)
              return interpolate;
            interpolate = x + '';
            return horizon;
          };
          horizon.x = function (z) {
            if (!arguments.length)
              return x;
            x = z;
            return horizon;
          };
          horizon.y = function (z) {
            if (!arguments.length)
              return y;
            y = z;
            return horizon;
          };
          horizon.width = function (x) {
            if (!arguments.length)
              return w;
            w = +x;
            return horizon;
          };
          horizon.height = function (x) {
            if (!arguments.length)
              return h;
            h = +x;
            return horizon;
          };
          return horizon;
        };
        var d3_horizonArea = d3.svg.area(), d3_horizonId = 0;
        function d3_horizonX(d) {
          return d[0];
        }
        function d3_horizonY(d) {
          return d[1];
        }
        function d3_horizonTransform(bands, h, mode) {
          return mode == 'offset' ? function (d) {
            return 'translate(0,' + (d + (d < 0) - bands) * h + ')';
          } : function (d) {
            return (d < 0 ? 'scale(1,-1)' : '') + 'translate(0,' + (d - bands) * h + ')';
          };
        }
      }());
      return d3;
    };
    $provide.decorator('d3', d3HorizonChartDecorator);
  }
]);
'use strict';
angular.module('d3').directive('horizonChart', [
  'd3',
  function (d3) {
    return {
      restrict: 'E',
      scope: {
        width: '@',
        height: '@',
        fixBands: '@',
        mode: '@',
        data: '=',
        bands: '=',
        onClick: '&',
        onHover: '&'
      },
      link: function postLink(scope, element, attrs) {
        var width = 800;
        var height = 600;
        var fixBands = 1;
        var mode = 'mirror';
        var interpolate = 'basic';
        var bands, data;
        var svg, chart;
        if (angular.isDefined(attrs.width))
          width = attrs.width;
        if (angular.isDefined(attrs.height))
          height = attrs.height;
        if (angular.isDefined(attrs.fixBands))
          fixBands = attrs.fixBands * 1 || 0;
        if (angular.isDefined(attrs.mode))
          mode = attrs.mode;
        if (angular.isDefined(attrs.interpolate))
          interpolate = attrs.interpolate;
        if (angular.isDefined(scope.data))
          data = scope.data;
        if (angular.isDefined(scope.bands))
          bands = scope.bands;
        if (angular.isUndefined(bands)) {
          bands = fixBands;
        }
        var parseSimpleData = function (data) {
          return data.value.map(function (value, i) {
            return [
              i,
              value
            ];
          });
        };
        var parseWithTimestamp = function (data) {
          return data.value.map(function (value, i) {
            return [
              data.timestamp[i],
              value
            ];
          });
        };
        var parseData = function (data) {
          if (angular.isDefined(data) && angular.isDefined(data.value) && angular.isDefined(data.timestamp)) {
            data = parseWithTimestamp(data);
          } else if (angular.isDefined(data) && angular.isDefined(data.value)) {
            data = parseSimpleData(data);
          } else {
            data = parseSimpleData({ value: [] });
          }
          return data;
        };
        var horizonChartFactory = function (data) {
          var rootElement = element[0];
          svg = d3.select(rootElement).append('svg').attr('width', width).attr('height', height);
          chart = d3.horizon().width(width).height(height).bands(bands).mode(mode).interpolate(interpolate);
          svg.data([parseData(data)]).call(chart);
        };
        horizonChartFactory(data);
        var updateChart = function () {
          chart.bands(scope.bands);
          svg.data([parseData(data)]).call(chart);
        };
        var doDeepWatch = true;
        scope.$watch('bands', updateChart, doDeepWatch);
        scope.$watch('data', updateChart, doDeepWatch);
      }
    };
  }
]);
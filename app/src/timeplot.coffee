#
# time series plot
#

Tooltip = require "./tooltip.coffee"
tooltip = new Tooltip()


module.exports = class TimePlot

  constructor : ->
    @container = d3.select("#time-series")
    @fmt = (d) -> "#{d} laugh#{if d != 1 then "s" else ""}"

  format : (@fmt) -> @

  update : (time_data, duration) ->
    @time_data = time_data or @time_data

    @y.domain [0, d3.max(@time_data, (d) -> d.value)*1.1]

    @line_path.datum @time_data
      .transition()
      .duration(duration ? 1000)
      .attr "d", @line

    @circles.data @time_data
      .attr "cx", (d) => @x d.date
      .attr "cy", (d) => @y d.value

    circles_dists = []
    @circles.each ->
      n = d3.select @
      circles_dists.push
        node : n
        x : parseFloat n.attr "cx"

    dformat = d3.time.format "%x"

    d3.select "#plexiglass"
      .on "mouseout", =>
        @circles.style "opacity", 0
        tooltip.position()
      .on "mousemove", =>
        @circles.style "opacity", 0
        mx = d3.mouse(@svg.node())[0]
        min = null
        min_dist = Infinity
        for c in circles_dists
          d = Math.abs(mx - c.x)
          if d < min_dist
            min_dist = d
            min = c.node
        data = min.data()[0]
        min.style "opacity", 1
        tooltip
          .text "#{dformat data.date} &mdash; #{@fmt data.value}"
          .position min.node(), @svg.node(), true
    return @


  render : (time_data) ->

    @time_data = time_data or @time_data

    bb = @container.node().getBoundingClientRect()

    @margin = top: 40, right: 30, bottom: 30, left: 50
    @width = bb.width - @margin.left - @margin.right
    @height = 300 - @margin.top - @margin.bottom

    @x = d3.time.scale()
        .range [0, @width]

    @y = d3.scale.linear()
        .range [@height, 0]

    @numberOfTicks = 10

    xAxis = d3.svg.axis()
        .scale @x
        .ticks(@numberOfTicks)
        .orient("bottom")

    @line = d3.svg.line()
        .x (d) => @x d.date
        .y (d) => @y d.value
        .interpolate "cardinal"

    @svg = @container.html("").append "svg"
        .attr "width", @width + @margin.left + @margin.right
        .attr "height", @height + @margin.top + @margin.bottom
      .append "g"
        .attr "transform", "translate(#{@margin.left},#{@margin.top})"

    @container.select "svg"
      .append "svg:defs"
      .append "svg:marker"
        .attr "id", "end"
        .attr "viewBox", "0 -5 10 10"
        .attr "refX", 0
        .attr "refY", 0
        .attr "fill", "#9477cb"
        .attr "markerWidth", 6
        .attr "markerHeight", 6
        .attr "orient", "auto"
      .append "svg:path"
        .attr "d", "M0,-5L10,0L0,5"

    @x.domain d3.extent @time_data, (d) -> d.date

    greenspan = [@x(@x.domain()[0]), @x(new Date("2006-1-31"))]
    bernanke = [@x(new Date("2006-2-1")), @x(@x.domain()[1])]


    xAxisGrid = d3.svg.axis().scale @x
      .ticks @numberOfTicks
      .tickSize -@height, 0
      .tickFormat ""
      .orient "top"

    y_title = @svg.append "g"

    y_text = y_title.append "text"
      .text "more laughs"

    y_text_bb = y_text.node().getBBox()

    y_title.append "line"
      .attr "class", "arrow"
      .attr "marker-end", "url(#end)"
      .attr
        x1 : y_text_bb.width + 5
        x2 : y_text_bb.width + 30
        y1 : -4
        y2 : -4

    h = @height
    y_title.attr "y", 0
      .attr "transform",  ->
        "rotate(270)translate(#{-h + @getBBox().width/2}, 0)"

    @svg.append('line')
      .attr 'class', 'chairman'
      .attr({
        "y1" : 0
        "y2" : 0
        "x1" : greenspan[0]
        "x2" : greenspan[1]
        })

    @svg.append('line')
      .attr 'class', 'chairman'
      .attr({
        "y1" : -10
        "y2" : -10
        "x1" : bernanke[0]
        "x2" : bernanke[1]
        })

    @svg.append('text')
      .text "Greenspan"
      .attr({
          "x" : ->
            (greenspan[1] - greenspan[0]) / 2 + greenspan[0] - @getBBox().width/2
          "y" : -5
        })

    @svg.append('text')
      .text "Bernanke"
      .attr({
          "x" : ->
            (bernanke[1] - bernanke[0]) / 2 + bernanke[0] - @getBBox().width/2
          "y" : -15
        })

    @svg.append "g"
      .classed "x", true
      .classed "grid", true
      .call xAxisGrid

    @svg.append "g"
        .attr "class", "x axis"
        .attr "transform", "translate (0,#{@height})"
        .call xAxis

    @line_path = @svg.append "path"
      .attr "class", "line"

    @circles = @svg.append "g"
      .selectAll "circle"
      .data @time_data
      .enter().append "circle"
      .attr "r", 5
      .attr "cx", (d) => @x d.date
      .attr "cy", (d) => @y d.value

    return @update(time_data, 0)







#
# The Fed's Laughter, Through the Years
# @bsouthga
#


d3 = require 'd3'
joke_data = require "../json/laughter.json"
Tooltip = require "./tooltip.coffee"
pym = require 'pym.js'
urlparams = require "./urlparams.coffee"


params = urlparams()

if params.hide_source
  d3.selectAll '.source'
    .classed 'show', false


class TimePlot

  constructor : ->
    @container = d3.select("#time-series")
    @fmt = (d) -> "#{d} laugh#{if d != 1 then "s" else ""}"
    @tooltip = new Tooltip()

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
        @tooltip.position()
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
        @tooltip
          .text "#{dformat data.date}<hr/>#{@fmt data.value}"
          .position min.node(), @svg.node(), true
    return @


  render : (time_data) ->

    @time_data = time_data or @time_data

    bb = @container.node().getBoundingClientRect()

    @margin = top: 40, right: 40, bottom: 30, left: 20
    @width = bb.width - @margin.left - @margin.right
    @height = 300 - @margin.top - @margin.bottom

    @x = d3.time.scale()
        .range [0, @width]
        .nice()

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
        .attr "fill", "#188754"
        .attr "markerWidth", 6
        .attr "markerHeight", 6
        .attr "orient", "auto"
      .append "svg:path"
        .attr "d", "M0,-5L10,0L0,5"

    @x.domain d3.extent @time_data, (d) -> d.date

    greenspan = [@x(@x.domain()[0]), @x(new Date("2006-01-31"))]
    bernanke = [@x(new Date("2006-02-01")), @x(@x.domain()[1])]


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
        x1 : y_text_bb.width + 10
        x2 : y_text_bb.width + 35
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


date_sort = (a, b) ->
  (a.date < b.date) - (a.date > b.date)

time_total = for date, v of joke_data["meta"]
  {value : v["jokes"], date : new Date date}

time_per_page = for date, v of joke_data["meta"]
  {value : (v["jokes"]/v["pages"]), date : new Date date}

time_total.sort date_sort
time_per_page.sort date_sort

T = new TimePlot()

T.render time_total

button_click = (button, plot, callback) ->
  d3.select button
    .on "click", ->
      id = @id
      d3.selectAll "#{plot}.buttons button"
        .classed 'selected', -> id == @id
      callback()

button_click "#per-page", ".series", ->
  T.update time_per_page
   .format (d) -> "#{Math.round(d*1000)/1000} laughs<br/>per page"

button_click '#total-series', ".series", ->
  T.update time_total
   .format (d) -> "#{d} laugh#{if d != 1 then "s" else ""}"

resize_timeout = null

reRender = ->
  clearTimeout resize_timeout
  resize_timeout = setTimeout ->
    T.render()
  , 100

d3.select window
  .on "resize", reRender

pymChild = new pym.Child { renderCallback: reRender }



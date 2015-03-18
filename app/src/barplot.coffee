#
# Who is the funniest in the FOMC?
# @bsouthga
#


d3 = require 'd3'
joke_data = require "../json/laughter.json"
pym = require 'pym.js'
urlparams = require "./urlparams.coffee"



params = urlparams()

if params.hide_source
  d3.selectAll '.source'
    .classed 'show', false

if params.small_version
  d3.select '#bar-chart-container'
    .classed 'small_version', true
  opacity = (d, i) => +(i < 18)
else
  opacity = -> d3.select(@).style('opacity')


class BarPlot

  constructor : ->
    @container = d3.select '#bar-chart'
    @property = "jokes"

  sort : (@property, duration) ->

    @bars.select('text.label')
      .style('opacity', 0)

    @bars
      .sort (A, B) =>
        a = A[@property]
        b = B[@property]
        (a < b) - (a > b)
      .transition()
      .duration(duration ? 2000)
      .attr 'transform',  (d, i) => "translate(0, #{@y(i)})"
      .each 'end', (d, i) =>
        if (i == 0)
          @bars.select('text.label')
            .style('opacity', 1)

    return @update(null, duration)


  update : (joke_data, duration) ->
    @joke_data = joke_data or @joke_data

    if joke_data
      @bars.data joke_data

    barHeight = @barHeight
    x = @x
    prop = @property
    fmt = if prop == "ratio"
            (d) -> "(#{d['jokes']}/#{d['mentions']})"
          else
            (d) -> d[prop]

    x.domain [0, d3.max(@joke_data, (d) -> d[prop])]

    @bars.select('text.name')
      .transition()
      .duration(duration ? 2000)
      .attr 'x', -> -@getBBox().width - 10
      .attr 'y', -> barHeight/2 + @getBBox().height/4
      .style 'opacity', opacity

    @bars.select('rect')
      .transition()
      .duration(duration ? 2000)
      .attr 'width', (d) => @x(d[prop])
      .style 'opacity', opacity

    @bars.select('text.label')
      .attr 'class', 'label'
      .text fmt
      .attr 'x', (d) ->
        pad = 5
        v = x(d[prop])
        w = @getBBox().width
        if ((v - pad*2) > w)
          v - w - pad
        else
          d3.select(@).classed('small', true)
          (v + pad)
      .attr 'y', ->
        barHeight/2 + @getBBox().height/4
      .style 'opacity', opacity

    return @



  render : (joke_data, alt_width) ->
    @joke_data = joke_data or @joke_data

    bb = @container.node().getBoundingClientRect()

    margin = top: 0, right: 40, bottom: 10, left: 120
    @width = width = (alt_width or bb.width) - margin.left - margin.right
    @height = 2000 - margin.top - margin.bottom

    @svg = @container.html('').append 'svg'
        .attr 'class', 'chart'
        .attr 'width', @width + margin.left + margin.right
        .attr 'height', @height + margin.top + margin.bottom
      .append 'g'
        .attr 'transform', 'translate(' + margin.left + ',' + margin.top + ')'

    @barHeight = @height / @joke_data.length

    @x = x = d3.scale.linear()
          .range [0, @width]

    @y = y = d3.scale.ordinal()
          .domain d3.range @joke_data.length
          .rangeRoundBands [0, @height], 0.5, 0

    @bars = @svg.append 'g'
      .selectAll 'bar'
      .data @joke_data
      .enter().append 'g'
      .attr 'class', 'bar'
      .attr 'transform', (d, i) -> "translate(0, #{y(i)})"

    @bars.append('text')
      .attr 'class', 'name'
      .text (d) -> d.name

    @bars.append('rect')
      .attr 'height', @barHeight - 1

    @bars.append('text')
      .attr 'class', 'label'


    if joke_data
      return @update @joke_data, 0
    else
      return @sort @property, 0



# open links in new tabs
d3.selectAll 'a'
  .attr 'target', '__blank'

getJokes = (date, prop) ->
  joke_data["jokes"][date].sort (A, B) ->
    a = A[prop]
    b = B[prop]
    (a < b) - (a > b)

joke_arr = for j in getJokes "total", "jokes"
  j.ratio = j['jokes'] / j['mentions']
  j


button_click = (button, plot, callback) ->
  d3.select button
    .on "click", ->
      id = @id
      d3.selectAll "#{plot}.buttons button"
        .classed 'selected', -> id == @id
      callback()

B = new BarPlot()

B.render joke_arr

button_click '#total-bar', ".bar", ->
  B.sort("jokes")

button_click '#success-pct', ".bar", ->
  B.sort("ratio")

resize_timeout = null

reRender = ->
  clearTimeout resize_timeout
  resize_timeout = setTimeout ->
    B.render()
  , 100

pymChild = new pym.Child { renderCallback: reRender }




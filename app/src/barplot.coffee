
d3 = require 'd3'

module.exports = class BarPlot

  constructor : ->
    @container = d3.select '#bar-chart'
    @property = "jokes"

  sort : (@property) ->
    @bars
      .sort (A, B) =>
        a = A[@property]
        b = B[@property]
        (a < b) - (a > b)
      .transition()
      .duration(2000)
      .attr 'transform',  (d, i) => "translate(0, #{@y(i)})"
    @update()


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
      .attr 'x', -> -@getBBox().width - 10
      .attr 'y', -> barHeight/2 + @getBBox().height/2

    @bars.select('rect')
      .transition()
      .duration(duration ? 2000)
      .attr 'width', (d) => @x(d[prop])

    @bars.select('text.label')
      .attr 'class', 'label'
      .text fmt
      .transition()
      .duration(duration ? 2000)
      .attr 'x', (d) ->
        pad = 5
        v = x(d[prop])
        w = @getBBox().width
        if ((v - pad*2) > w)
          v - w - pad
        else
          d3.select(@).classed('small', true)
          (v + pad)
      .attr 'y', -> barHeight/2 + @getBBox().height/2

    return @



  render : (joke_data) ->
    @joke_data = joke_data or @joke_data

    bb = @container.node().getBoundingClientRect()

    margin = top: 0, right: 10, bottom: 10, left: 120
    @width = width = bb.width - margin.left - margin.right
    @height = 2000 - margin.top - margin.bottom

    @svg = @container.html('').append 'svg'
        .attr 'class', 'chart'
        .attr 'width', @width + margin.left + margin.right
        .attr 'height', @height + margin.top + margin.bottom
      .append 'g'
        .attr 'transform', 'translate(' + margin.left + ',' + margin.top + ')'

    @barHeight = @height / joke_data.length

    @x = x = d3.scale.linear()
          .range [0, @width]

    @y = y = d3.scale.ordinal()
          .domain d3.range @joke_data.length
          .rangeRoundBands [0, @height], 0.5, 0

    @bars = @svg.append 'g'
      .selectAll 'bar'
      .data joke_data
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

    return @update @joke_data, 0



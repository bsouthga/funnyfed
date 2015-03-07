
d3 = require 'd3'

module.exports = (joke_arr) ->

  margin = { top: 50, right: 10, bottom: 10, left: 180 }
  width = 600 - margin.left - margin.right
  height = 2000 - margin.top - margin.bottom

  svg = d3.select('body').append('svg')
      .attr('class', 'chart')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
    .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

  svg.append('text')
    .attr('class', 'title')
    .text('Laughs scored at Federal Open Market Committee meetings')
    .attr 'x', -> (width - margin.left - @getBBox().width)/2
    .attr 'y', -> -@getBBox().height


  barHeight = height / joke_arr.length

  x = d3.scale.linear()
        .domain([0, d3.max(joke_arr, (d) -> d.jokes)])
        .range([0, width])

  bars = svg.append('g')
    .selectAll('bar')
    .data(joke_arr)
    .enter().append('g')
    .attr('class', 'bar')
    .attr 'transform', (d, i) -> "translate(0, #{i*barHeight})"

  bars.append('text')
    .attr 'class', 'name'
    .text (d) -> d.name
    .attr 'x', -> -@getBBox().width - 10
    .attr 'y', -> barHeight/2 + @getBBox().height/2

  bars.append('rect')
    .attr 'height', barHeight - 1
    .attr 'width', (d) -> x(d.jokes)

  bars.append('text')
    .attr 'class', 'label'
    .text (d) -> d.jokes
    .attr 'x', (d) ->
      pad = 5
      v = x(d.jokes)
      w = @getBBox().width
      if ((v - pad*2) > w)
        v - w - pad
      else
        d3.select(@).classed('small', true)
        (v + pad)
    .attr 'y', -> barHeight/2 + @getBBox().height/2
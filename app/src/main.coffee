#
# plots of laughing at FOMC meetings
# @bsouthga
# 03/07/15
#

BarPlot = require "./barplot.coffee"
TimePlot = require "./timeplot.coffee"
joke_data = require "../json/laughter.json"

getJokes = (date, prop) ->
  joke_data["jokes"][date].sort (A, B) ->
    a = A[prop]
    b = B[prop]
    (a < b) - (a > b)

date_sort = (a, b) ->
  (a.date < b.date) - (a.date > b.date)

time_total = for date, v of joke_data["meta"]
  {value : v["jokes"], date : new Date date}

time_per_page = for date, v of joke_data["meta"]
  {value : (v["jokes"]/v["pages"]), date : new Date date}

time_total.sort date_sort
time_per_page.sort date_sort

joke_arr = for j in getJokes "total", "jokes"
  j.ratio = j['jokes'] / j['mentions']
  j


T = new TimePlot()
B = new BarPlot()

T.render time_total
B.render joke_arr

button_click = (button, plot, callback) ->
  d3.select button
    .on "click", ->
      id = @id
      d3.selectAll "#{plot}.buttons button"
        .classed 'selected', -> id == @id
      callback()

button_click "#per-page", ".series", ->
  T.update time_per_page
   .format (d) -> "#{Math.round(d*1000)/1000} laughs per page"

button_click '#total-series', ".series", ->
  T.update time_total
   .format (d) -> "#{d} laugh#{if d != 1 then "s" else ""}"

button_click '#total-bar', ".bar", ->
  B.sort("jokes")

button_click '#success-pct', ".bar", ->
  B.sort("ratio")

resize_timeout = null

d3.select window
  .on "resize", ->
    clearTimeout resize_timeout
    resize_timeout = setTimeout ->
      T.render()
      B.render()
    , 100

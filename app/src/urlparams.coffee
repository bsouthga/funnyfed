
module.exports = ->
  query = location.search.substr 1
  result = {}
  query.split("&").forEach (part) ->
    item = part.split "="
    result[item[0]] = decodeURIComponent item[1]
  result

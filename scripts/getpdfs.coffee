#!/usr/bin/env coffee

#
# scrape fed website for pdfs
#
ccle
cheerio = require("cheerio")
request = require("request")
fs = require('fs')

fed = "http://www.federalreserve.gov"

for year in [1990..2008]

  url = "#{fed}/monetarypolicy/fomchistorical#{year}.htm"

  request url, (error, res, body) ->

    if not error and res.statusCode is 200

      $ = cheerio.load body

      transcripts = $("a")
        .filter -> $(@).text().match /.*[Tt]ranscript.*/
        .filter -> $(@).attr("href").match /.pdf$/
        .map -> $(@).attr("href")

      for f in transcripts
        do (f) ->
          [..., filename] = f.split('/')
          request "#{fed}#{f}", (e, res, body) ->
            console.log "writing #{filename}"
            if not e and res.statusCode is 200
              fs.writeFile "../pdfs/#{filename}", body

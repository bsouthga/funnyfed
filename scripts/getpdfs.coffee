#!/usr/bin/env coffee

#
# scrape fed website for pdfs
#
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
          outfname = "../pdfs/#{filename}"
          request "#{fed}#{f}"
            .pipe fs.createWriteStream outfname

# convert fed pdfs to text
# @bsouthga
# 03/05/15

import string
import PyPDF2
import glob
import json
import re


laugh_regex = re.compile(r"""
  # name of jokester
  (?P<name>(?:CHAIRMAN|M[RS]+)\.?\s+[A-Z\s]+\.?)
  # joke
  (?P<joke>
    (?:(?!(?:CHAIRMAN|M[RS]+)\.?\s+[A-Z]+).)*
  )
  # people laughing
  \[[Ll]aughter.*?\]
""", re.X | re.M | re.S)


def printable(s):
  return ''.join(filter(lambda x: x in string.printable, s))


def pdfToText(filename):
  with open(filename, 'rb') as inpdf:
    pdf = PyPDF2.PdfFileReader(inpdf)
    if pdf.isEncrypted:
      pdf.decrypt("")
    pdf_text = "\n".join([
      printable(pdf.getPage(n).extractText())
      for n in range(pdf.numPages)
    ])

  return pdf_text


def fullJSON():

  meeting = re.compile(r"""
    .*
    # year
    (\d\d\d\d)
    # month
    (\d\d)
    # day
    (\d\d)
    # kind
    (\w+)
    \.pdf
  """, re.X)

  out = []
  for fname in glob.glob('../pdfs/*.pdf'):
    print("parsing {}".format(fname))
    year, month, day, kind = meeting.match(fname).groups()
    text = pdfToText(fname)
    out.append({
      "year" : year,
      "month" : month,
      "day" : day,
      "kind" : kind,
      "text" : text
    })

  with open('../txt/full.json', 'w') as outjson:
    json.dump(out, outjson)


def makeFullText():

  full_text = "\n".join([
    pdfToText(f)
    for f in glob.glob('../pdfs/*.pdf')
  ])

  with open('../txt/full_text.txt', 'w') as out:
    out.write(full_text)


def parse():
  with open('../txt/full_text.txt') as fullfile:
    matches = []
    for m in laugh_regex.finditer(fullfile.read()):
      df = m.groupdict()
      for joke in re.split(r"\[[Ll]aughter.*?\]", df['joke']):
        matches.append({
          "name" : df['name'],
          "joke" : joke.strip()
        })
  return matches


def toTSV(matches):
  with open('../txt/jokes.tsv', 'w') as outtsv:
    outtsv.write("\n".join(["name\tjoke"] + [
      "\t".join([j['name'], re.sub( '\s+', ' ', j['joke'] ).strip()])
      for j in matches
    ]))

if __name__ == '__main__':

  #toTSV(parse())

  fullJSON()

  # with open('../app/json/jokes.json', 'w') as outjson:
  #   jokes = parse()
  #   out = {}
  #   for joke in jokes:
  #     try:
  #       out[joke['name']].append(joke['joke'])
  #     except KeyError:
  #       out[joke['name']] = [joke['joke']]
  #   json.dump(out, outjson, indent=2, sort_keys=True)




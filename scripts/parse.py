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



def parse():
  with open('../txt/full.json') as meetingjson:
    meetings = json.load(meetingjson)
    matches = []
    for meeting in meetings:
      print("Parsing {kind} {month}/{day}/{year}".format(**meeting))
      for m in laugh_regex.finditer(meeting['text']):
        df = m.groupdict()
        for joke in re.split(r"\[[Ll]aughter.*?\]", df['joke']):
          matches.append({
            "year" : meeting['year'],
            "month" : meeting['month'],
            "day" : meeting['day'],
            "kind" : meeting['kind'],
            "name" : df['name'],
            "joke" : joke.strip()
          })
  with open('../app/json/jokes.json', 'w') as outjson:
    json.dump(matches, outjson)


def perPerson():
  with open('../app/json/jokes.json') as jokejson:
    jokes = json.load(jokejson)
  out = {}
  for j in jokes:
    record = {
      "year" : j['year'],
      "month" : j['month'],
      "day" : j['day'],
      "kind" : j['kind'],
      "length" : len(j['joke'])
    }
    try:
      out[j['name']].append(record)
    except KeyError:
      out[j['name']] = [record]

  with open('../app/json/people.json', 'w') as people:
    json.dump(out, people)


if __name__ == '__main__':
  perPerson()




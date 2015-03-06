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
  (?P<name>(?:CHAIRMAN|M[RS]+)\.?\s+[A-Z\s]+)
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
    pdf_text = "\n".join([
      printable(pdf.getPage(n).extractText())
      for n in range(pdf.numPages)
    ])

  return pdf_text


def makeFullText():

  full_text = "\n".join([
    pdfToText(f)
    for f in glob.glob('pdfs/*.pdf')
  ])

  with open('full_text.txt', 'w') as out:
    out.write(full_text)


def parse():
  with open('full_text.txt') as fullfile:
    matches = []
    for m in laugh_regex.finditer(fullfile.read()):
      df = m.groupdict()
      for joke in re.split(r"\[[Ll]aughter.*?\]", df['joke']):
        matches.append({
          "name" : df['name'],
          "joke" : joke
        })
  return matches


if __name__ == '__main__':
  with open('matches.json', 'w') as outjson:
    jokes = parse()
    print(len(jokes))
    json.dump(jokes, outjson, indent=2, sort_keys=True)




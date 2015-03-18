# convert fed pdfs to text
# @bsouthga
# 03/05/15

import string
import PyPDF2
import glob
import json
import re
import datetime

speaking_regex = re.compile(r"""
  # name of jokester
  (?P<name>(?:CHAIRMAN|M[RS]+)\.?\s+[A-Z\s]+\.?)
""", re.X | re.M | re.S)


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


# convert text string to only printable characters
printable = lambda s: "".join(filter(lambda x: x in string.printable, s))


def pdfToText(filename):
  with open(filename, "rb") as inpdf:
    pdf = PyPDF2.PdfFileReader(inpdf)
    if pdf.isEncrypted:
      pdf.decrypt("")
    pdf_text = "\n".join([
      printable(pdf.getPage(n).extractText())
      for n in range(pdf.numPages)
    ])

  return {"text" : pdf_text, "pages" : pdf.numPages}


def meetingTextJSON():

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
  for fname in glob.glob("../pdfs/*.pdf"):
    print("parsing {}".format(fname))
    year, month, day, kind = meeting.match(fname).groups()
    pdf = pdfToText(fname)
    out.append({
      "year" : year,
      "month" : month,
      "day" : day,
      "kind" : kind,
      "pages" : pdf["pages"],
      "text" : pdf["text"]
    })

  with open("../txt/meeting_text.json", "w") as outjson:
    json.dump(out, outjson)



def parse():

  with open("../txt/meeting_text.json") as meetingjson:

    meetings = json.load(meetingjson)

    data = {
      "jokes" : [],
      "mentions" : [],
      "meta" : {}
    }

    for meeting in meetings:

      print("Parsing {kind} {month}/{day}/{year}".format(**meeting))

      date = "{year}-{month}-{day}".format(**meeting)

      data["meta"][date] = {
        "kind" : meeting["kind"],
        "pages" : meeting["pages"],
        "jokes" : 0
      }

      # get times where laughter occured
      for m in laugh_regex.finditer(meeting["text"]):
        df = m.groupdict()
        for joke in re.split(r"\[[Ll]aughter.*?\]", df["joke"]):
          data["jokes"].append({
            "date" : date,
            "name" : df["name"]
          })
          data["meta"][date]["jokes"] += 1

      # get all instances where someone spoke
      for m in speaking_regex.finditer(meeting["text"]):
        df = m.groupdict()
        data["mentions"].append({
          "date" : date,
          "name" : df["name"]
        })

  with open("../app/json/full_data.json", "w") as outjson:
    json.dump(data, outjson)



def clean(name):
  name = name.replace(".", "").split(" ")[1]
  if name == "GREENPAN":
    name = "GREENSPAN"
  if name == "D":
    name = ""
  return name



# create json for vizualization
def vizJSON():

  with open("../app/json/full_data.json") as full_data_json:
    full_data = json.load(full_data_json)

  jokesters = {clean(r["name"]) for r in full_data["jokes"]}

  tmp = {n : {} for n in jokesters if n}

  # chairman count
  chairman = {
    "BERNANKE" : { "pre" : 0, "chairman": 0, "post" : 0, "dates" : [
      datetime.datetime(2006, 2, 1),
      datetime.datetime(2014, 1, 31)
    ]},
    "GREENSPAN" : { "pre" : 0, "chairman": 0, "post" : 0, "dates" : [
      datetime.datetime(1987, 8, 11),
      datetime.datetime(2006, 1, 31)
    ]},
  }


  def dateRange(d, bounds):
    date_object = datetime.datetime.strptime(d, '%Y-%m-%d')
    if date_object < bounds[0]:
      return "pre"
    if date_object > bounds[1]:
      return "post"
    return "chairman"


  for m in full_data["mentions"]:
    name = clean(m["name"])
    date = m["date"]
    if name in tmp:
      if date not in tmp[name]:
        tmp[name][date] = {"mentions" : 0, "jokes" : 0}
      tmp[name][date]["mentions"] += 1

  for j in full_data["jokes"]:
    name = clean(j["name"])
    date = j["date"]
    if name:
      tmp[name][date]["jokes"] += 1
    # count chairman jokes
    if name in chairman:
      chairman[name][dateRange(date, chairman[name]["dates"])] += 1

  # switch name / date in dict
  out = {"meta" : full_data['meta'], "jokes" : {"total" : {}}}
  for name in tmp:
    out["jokes"]["total"][name] = {"mentions" : 0, "jokes" : 0}
    for date in tmp[name]:
      # if date not in out["jokes"]:
      #   out["jokes"][date] = {}
      # out["jokes"][date][name] = tmp[name][date]
      out["jokes"]["total"][name]["jokes"] += tmp[name][date]["jokes"]
      out["jokes"]["total"][name]["mentions"] += tmp[name][date]["mentions"]

  # list of jokes for each date
  out["jokes"]["total"] = [
    {
      "name" : name,
      "jokes" : out["jokes"]["total"][name]["jokes"],
      "mentions" : out["jokes"]["total"][name]["mentions"]
    }
    for name in out["jokes"]["total"]
  ]

  print(chairman)

  with open("../app/json/laughter.json", "w") as laughter:
    json.dump(out, laughter)


if __name__ == "__main__":
  # meetingTextJSON()
  # parse()
  vizJSON()




# how funny is the FOMC?

[view interactive](http://bsouthga.github.io/funnyfed/)

[article in the Atlantic](http://bsouthga.github.io/funnyfed/)

### recreating this project

requirements
- NodeJS
- grunt-cli
- coffeescript
- python 2.7+
- PyPDF2

install node dependencies...
```shell
npm install
```

collecting the pdfs...
```shell
mkdir -p pdfs
cd ./scripts
coffee getpdfs.coffee
```

parsing pdfs...
```shell
mkdir -p app/json
mkdir -p txt
cd ./scripts
python parse.py
```

building vizualization...
```shell
grunt
```



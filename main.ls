require! <[request cheerio fs async prelude-ls ./config]>
_ = prelude-ls

{base-form, form-step1, form-step2, form-step3, form-step4, form-step5} = config

jar = request.jar!
request = request.defaults jar: jar


fetch = (options, next) ->

  url = options.url || 'https://cris.hpa.gov.tw/pagepub/Home.aspx?itemNo=cr.q.10'
  method = options.method || 'POST'
  (error, res, body) <- request do
    url: url
    method: method
    headers:
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131'
      'Referer': 'https://cris.hpa.gov.tw/pagepub/Home.aspx?itemNo=cr.q.10'
    strictSSL: false
    form: options.form

  $ = cheerio.load body
  event-validation = $('#__EVENTVALIDATION').val!
  viewstate-id = $('#__VIEWSTATE_ID').val!
  base-form.__EVENTVALIDATION = event-validation
  base-form.__VIEWSTATE_ID = viewstate-id
  next error, res, body, form: base-form

export-file = (area-code, next) ->

  (err, res, body, it)<- fetch do
    url: 'https://cris.hpa.gov.tw/pagepub/Home.aspx?itemNo=cr.q.10'
    method: 'GET'


  form = {}
  form <<<< it.form <<<< form-step1

  (err, res, body, it)<- fetch do
    form: form


  form = {}
  form <<<< it.form <<<< form-step2

  (err, res, body, it)<- fetch do
    form: form

  form = {}
  form <<<< it.form <<<< form-step3

  (err, res, body, it)<- fetch do
    form: form

  form = {}
  form <<<< it.form <<<< form-step4 <<<< area-code

  (err, res, body, it)<- fetch do
    form: form

  form = {}
  form <<<< it.form <<<< form-step5
  (err, res, body, it)<- fetch do
    form: form

  #TODO error handle here
  #console.log res.headers.location

  report-url = 'https://cris.hpa.gov.tw' + res.headers.location

  (err, res, body, it)<- fetch do
    url: report-url
    method: 'GET'
    jar: jar
  $ = cheerio.load body
  script = $('script')[5]
  script-text = $(script).text!
  matched = script-text.match /\\(\/Reserved.ReportViewerWebControl.axd.+&OpType=Export.+&Format=)/

  export-url = 'https://cris.hpa.gov.tw' + matched.1 + 'Excel'
  # (err, res, body, it)<- fetch do
  #   url: export-url
  #   method: 'GET'
  # $ = cheerio.load body
  # paths = $('#report').attr('src') / '&'

  # xls-url = 'https://cris.hpa.gov.tw' + paths.0 + '&' + paths.1 + '&' + paths.2 + '&' + paths.3 + '&' + paths.4 + '&' + paths.5
  # xls-url += '&OpType=Export&FileName=CrReportN_A01_C&ContentDisposition=AlwaysAttachment&Format=Excel'

  file-name = _.values area-code
  console.log "Export to data/#{file-name.0}.xls"

  file = fs.createWriteStream "data/#{file-name.0}.xls"
  do
    error, res, body <- request do
      url: export-url
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131'
      strictSSL: false
      jar: jar
    next null, "Export to data/#{file-name.0}.xls"
  .pipe file

main = (lists)->
  fs.mkdir 'data' unless fs.existsSync 'data'

  tasks = []
  do
    code <- lists.forEach
    tasks.push (cb) ->
      error, message <- export-file code
      cb null, message

  err, results<- async.series tasks
  if results.length is lists.length
    console.log 'All Done'

main config.area-lists
#export-file {'WR1_1_ctl25_12':'CRA_3213'}#config.area-lists.0
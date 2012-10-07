vertx  = require 'vertx'
_      = require 'web/js/lib/underscore'

logger = vertx.logger;
client = vertx.createHttpClient().setHost('omatlahdot.hkl.fi').setMaxPoolSize(3)

# Execute f and ensure close() is called on closeable after it
withOpen = (closeable, f) ->
  try
    f()
  finally
    closeable.close()

# Construct the outgoing SOAP request for the given attributes
makeGetNextDeparturesExtRequest = (stopCode, date, time, n) ->
  """
  <soapenv:Envelope
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:urn="urn:seasam">
    <soapenv:Header/>
    <soapenv:Body>
      <urn:getNextDeparturesExt soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        <String_1 xsi:type="xsd:string">#{stopCode}</String_1>
        <Date_2 xsi:type="xsd:dateTime">#{date}T#{time}</Date_2>
        <int_3 xsi:type="xsd:int">#{n}</int_3>
      </urn:getNextDeparturesExt>
   </soapenv:Body>
  </soapenv:Envelope>
  """

# Execute the request for the departures with the given attributes.
# The callback is used as the response handler.
getNextDepartures = (stopCode, date, time, n, callback) ->
  try
    logger.info "Omat lahdot outgoing: #{JSON.stringify(arguments)}"
    request = client.post '/interfaces/kamo', (r) -> callback(null, r)
    request.headers()['Content-Type'] = "text/xml; charset=UTF-8"
    request.end(makeGetNextDeparturesExtRequest(stopCode, date, time, n))
  catch e
    callback(e)

# From the returned SOAP XML Response, parse the relevant
# floor height information. Uses StAX for parsing.
parseDepartureFloorHeights = (data, date) ->
  reader = undefined
  elStack = []
  result = []
  current = undefined
  withOpen reader = javax.xml.stream.XMLInputFactory.newInstance().createXMLEventReader(new java.io.StringReader(data)), ->
    while reader.hasNext()
      evt = reader.nextEvent()
      if evt.isStartElement()
        elStack.push evt.getName().getLocalPart()
        if _(elStack).last() is "item"
          current = {info: '', lineCode: '', date: date, time: ''}
      else if evt.isEndElement()
        if _(elStack).last() is "item"
          current.highFloored = (current.info is 'e')
          delete current.info
          result.push current
          current = undefined
        elStack.pop()
      else if evt.isCharacters()
        switch _(elStack).last()
          when "info"  then current.info += evt.getData()
          when "route" then current.lineCode += evt.getData()
          when "time"  then current.time += evt.getData()
  result

# Find the floor heights for the departures with the given parameters.
getDepartureFloorHeights= (stopCode, date, time, n, callback) ->
  time += ':00' unless time.length is 8
  getNextDepartures stopCode, date, time, n, (error, res) ->
    if error? or res.statusCode isnt 200
      callback(error)
    else
      res.bodyHandler (body) ->
        data = body.getString(0, body.length())
        callback null, parseDepartureFloorHeights(data, date)

module.exports =
  getDepartureFloorHeights: getDepartureFloorHeights



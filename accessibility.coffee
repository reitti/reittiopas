vertx      = require 'vertx'
omatlahdot = require 'omatlahdot'
cache      = require 'cache'
_          = require 'web/js/lib/underscore'
moment     = require 'web/js/lib/moment'
async      = require 'lib/async'

eb = vertx.eventBus

interestingTypes = [
  '2' # Trams
  '8' # U lines
  '36' # Kirkkonummi internal
  '39' # Kerava internal
]
interestingLineCodes = [
  '1024  1'
  '1024  2'
  '2085  1'
  '2085  2'
  '4364  1'
  '4364  2'
]

cacheTtl = 24 * 60 * 60 # One day

# Omat lahdot uses date format yyyy-MM-dd
dateToOmatFormat = (d) ->
  [d.substring(0, 4), d.substring(4, 6), d.substring(6, 8)].join('-')

# Omat lahdot usest ime format HH:mm. The time is exclusive so we need
# to subtract it by one minute.
timeToOmatFormat = (d) ->
  hours = parseInt(d.substring(8, 10), 10)
  minutes = parseInt(d.substring(10, 12), 10)
  if minutes > 0
    minutes -= 1
  else if hours > 0
    hours -= 1
    minutes = 59
  hourPad = if hours < 10 then '0' else ''
  minPad = if minutes < 10 then '0' else ''
  "#{hourPad}#{hours}:#{minPad}#{minutes}"

# We use the combined date and time format YYYYMMddHHmmm
dateTimeToNormalizedformat = (d, t) ->
  [d.substring(0, 4), d.substring(5, 7), d.substring(8, 10), t.substring(0, 2), t.substring(3, 5)].join('')

# Omat lähdöt only has information for a couple of days at a time. Don't even
# try to make requests outside that window
withinTimeWindow = (t) ->
  diff = moment(t, 'YYYYMMDDHHmm').diff(moment(), 'days', true)
  -1 <= diff <= 2

# Extract only those legs from the routes that are interesting from an accessibility perspective.
getInterestingLegs = (routes) ->
  legs = []
  for route in routes
    for leg in route[0].legs
      interestingLine = _.contains(interestingTypes, leg.type) or _.contains(interestingLineCodes, leg.code)
      if interestingLine and withinTimeWindow(leg.locs[0]?.depTime)
       legs.push(leg) 
  legs

# We cache the info by line, stop, and time.
makeCacheKey = (lineCode, stopCode, time) ->
  "#{lineCode}-#{stopCode}-#{time}"

# See if we have cached information for any of the given legs.
# For the legs that have cached information, the information is attached.
# The remaining legs are passed to the callback.
attachCachedFloorHeights = (legs, callback) ->
  reduction = (remaining, leg, next) ->
    eb.send 'reitti.cache.get', key: makeCacheKey(leg.code, leg.locs[0]?.code, leg.locs[0]?.depTime), (res) ->
      if res.result?
        leg.highFloored = res.result.highFloored
      else
        remaining.push leg
      next(null, remaining)
  async.reduce legs, [], reduction, (error, remaining) -> callback(remaining)

# The Omat Lahdot API supports requesting departures for one stop at a time, and only
# returns intra-day departures. For that reason, divide our legs to distinct
# groups based on the stop and date, each of which will need to be requested separately.
getRequestGroups = (legs) ->
  _.values _.groupBy legs, (leg) -> "#{leg.locs[0]?.code}-#{dateToOmatFormat(leg.locs[0]?.depTime)}"

# Make the request for accessibility information for a single leg group (stop code + day).
# Attach the returned accessibility information to the legs.
# Omat Lahdot actually returns multiple departures _starting_ from the given
# time, and we cache them all for future use.
makeRequest = (legGroup, callback) ->
  legGroup = _.sortBy legGroup, (leg) -> leg.locs[0]?.depTime
  firstLeg = _.first(legGroup)
  date = dateToOmatFormat(firstLeg.locs[0]?.depTime)
  time = timeToOmatFormat(firstLeg.locs[0]?.depTime)
  omatlahdot.getDepartureFloorHeights firstLeg.locs[0]?.code, date, time, 100, (error, results) ->
    if error?
      callback(error)
    else
      for r in results
        datetime = dateTimeToNormalizedformat(r.date, r.time)
        eb.send 'reitti.cache.put', key: makeCacheKey(r.lineCode, firstLeg.locs[0]?.code, datetime), value: r, ttl: cacheTtl
        for matchedLeg in legGroup when r.lineCode = matchedLeg.code and datetime is matchedLeg.locs[0]?.depTime
          matchedLeg.highFloored = r.highFloored
      callback(null) 
    
# Request all accessibility information relevant to the given departures.
attachFloorHeights = (routes, callback) ->
  try
    interestingLegs = getInterestingLegs(routes)
    attachCachedFloorHeights interestingLegs, (remainingLegs) -> 
      legGroups = getRequestGroups(remainingLegs)
      async.map legGroups, makeRequest, callback
  catch exception
    callback(exception)

module.exports =
  attachFloorHeights: attachFloorHeights

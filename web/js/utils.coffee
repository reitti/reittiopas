define ->
  class Utils

    @transportTypes = ['bus', 'tram', 'metro', 'train', 'ferry']

    @transportColors =
      walk: '#1e74fc'
      1: '#193695' # Helsinki internal bus lines
      2: '#00ab66' # Trams
      3: '#193695' # Espoo internal bus lines
      4: '#193695' # Vantaa internal bus lines
      5: '#193695' # Regional bus lines
      6: '#fb6500' # Metro
      7: '#00aee7' # Ferry
      8: '#193695' # U-lines
      12: '#ce1141' # Commuter trains
      21: '#193695' # Helsinki service lines
      22: '#193695' # Helsinki night buses
      23: '#193695' # Espoo service lines
      24: '#193695' # Vantaa service lines
      25: '#193695' # Region night buses
      36: '#193695' # Kirkkonummi internal bus lines
      39: '#193695' # Kerava internal bus lines

    # From Date to yyyyMMddHHmmss
    @formatDateTime: (d) ->
      "#{@formatDate(d)}#{@formatTime(d, '')}"

    # From yyyyMMddHHmmss to Date
    @parseDateTime: (str) ->
      [all, year, month, date, hour, min] = str.match /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/
      new Date year, month - 1, date, hour, min

    # From Date to HH:mm
    @formatTime: (d, separator = ':') ->
      return null unless d instanceof Date
      hourZero = if d.getHours() < 10 then '0' else ''
      minZero = if d.getMinutes() < 10 then '0' else ''
      "#{hourZero}#{d.getHours()}#{separator}#{minZero}#{d.getMinutes()}"

    @formatHSLTime: (d) ->
      return null unless d instanceof Date
      minZero = if d.getMinutes() < 10 then '0' else ''
      hourZero = if d.getHours() < 10 then '0' else ''
      "#{hourZero}#{d.getHours()}#{minZero}#{d.getMinutes()}"

    @formatDate: (d, separator = '') ->
      return null unless d instanceof Date
      monthZero = if d.getMonth() + 1 < 10 then '0' else ''
      dateZero = if d.getDate() < 10 then '0' else ''
      "#{d.getFullYear()}#{separator}#{monthZero}#{d.getMonth() + 1}#{separator}#{dateZero}#{d.getDate()}"


    # From a numeric distance in meters to a formatted value
    @formatDistance: (d) ->
      if d < 900
        "#{d}m"
      else if d < 100000
        km = (d / 1000).toPrecision(2).replace '.', ','
        "#{km}km"
      else
        km = (d / 1000).toPrecision(3).replace '.', ','
        "#{km}km"

    @nextQuarterOfHour: (d) ->
      nextQuarter = Math.floor(d.getMinutes() / 15) + 1
      minutesToNext = nextQuarter * 15 - d.getMinutes()
      new Date(d.getTime() + minutesToNext * 60 * 1000)

    # (absolute) seconds between two dates
    @getDuration: (d1, d2) ->
      Math.abs(d1.getTime() - d2.getTime()) / 1000

    # From a number (of seconds) to a formatted value
    @formatDuration: (d) ->
      d = d / 60 # Seconds to minutes
      hours = Math.floor d / 60
      mins = Math.round d % 60
      if hours > 0 and mins > 0
        "#{hours}h #{mins}min"
      else if hours > 0
        "#{hours}h"
      else
        "#{mins}min"

    # Checks if the given geoposition is within the bounds supported
    # by this application (Greater Helsinki Area)
    @isWithinBounds: (location) ->
      {longitude: lng, latitude: lat} = location.coords
      24.152104 < lng < 25.535784 and 59.99907 < lat < 60.446654

    # Parses hh:mm into a Date object. The date part can be given as a parameter.
    @parseTime: (time, date = new Date()) ->
      timeZone = Math.round(date.getTimezoneOffset() / 60)
      timeZoneZeroPad = if Math.abs(timeZone) < 10 then '0' else ''
      timeZoneSign = if timeZone >= 0 then '-' else '+'
      dateString = "#{@formatDate(date, '-')}T#{time}#{timeZoneSign}#{timeZoneZeroPad}#{Math.abs(timeZone)}00"
      new Date(Date.parse(dateString))

    # Memoizes functions that do asynchronous work, and pass their results to a callback
    # function given as the last argument.
    @asyncMemoize: (f) ->
      cache = {}
      (args..., callback) ->
        cacheKey = JSON.stringify(args)
        if cached = cache[cacheKey]
          callback.apply null, cached
        else
          args.push (results...) ->
            cache[cacheKey] = results
            callback.apply null, results
          f.apply null, args

    @encodeURIComponent: (s) ->
      s = s.replace(/\s/g, '--').replace(/,/, '_')
      encodeURIComponent(s)

    @decodeURIComponent: (s) ->
      s = decodeURIComponent(s)
      s.replace(/--/g, ' ').replace(/_/g, ',')



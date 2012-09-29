define ['moment'], (moment) -> 
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

    @formatDateTimeForMachines: (d) ->
      moment(d).format('YYYYMMDDHHmmss')

    @parseDateTimeFromMachines: (str) ->
      moment(str, "YYYYMMDDHHmmss").toDate()

    @formatDateForMachines: (d) ->
      moment(d).format("YYYYMMDD")

    @formatTimeForMachines: (d) ->
      moment(d).format("HHmm")

    @formatTimeForHumans: (d) ->
      moment(d).format("HH:mm")

    @formatDateForHumans: (d) ->
      moment(d).format("DD.MM.YYYY")

    @formatDateForHTML5Input: (d) ->
      moment(d).format("YYYY-MM-DD")

    @parseDateAndTimeFromHTML5Input: (date, time) ->
      moment("#{date} #{time}", "YYYY-MM-DD HH:mm").toDate()

    @addMinutes: (date, n) ->
      new Date(date.getTime() + n * 60 * 1000)
      
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
      minutesToNextQuarter = nextQuarter * 15 - d.getMinutes()
      new Date(d.getTime() + minutesToNextQuarter * 60 * 1000)

    @isSameMinute: (d1, d2) ->
      moment(d1).endOf('minute').diff(moment(d2).endOf('minute')) is 0

    # (absolute) seconds between two dates
    @getDuration: (d1, d2) ->
      Math.abs moment(d1).diff(moment(d2), 'seconds')

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
      s = s.replace(/\s/g, '--').replace(/,/g, '_')
      encodeURIComponent(s)

    @decodeURIComponent: (s) ->
      s = decodeURIComponent(s)
      s.replace(/--/g, ' ').replace(/_/g, ',')

    @getScrollBarWidth: () ->
      div = $('<div style="width:50px;height:50px;overflow:hidden;position:absolute;top:-200px;left:-200px;"><div style="height:100px;"></div></div>')
      $('body').append(div)
      w1 = $('div', div).innerWidth()
      div.css('overflow-y', 'auto')
      w2 = $('div', div).innerWidth()
      $(div).remove()
      w1 - w2

    @toPercentage: (num) ->
      "#{num * 100}%"

    @isNativeDateInputSupported: () ->
      input = document.createElement('input')
      input.setAttribute 'type', 'date'
      input.type isnt 'text'



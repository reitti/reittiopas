define ->
  class Utils

    @isLocalStorageEnabled: -> 
      typeof(Storage) isnt "undefined"

    # From yyyyMMddHHmmss to Date
    @parseDateTime: (str) ->
      [all, year, month, date, hour, min] = str.match /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/
      new Date year, month, date, hour, min
      
    # From Date to H:mm
    @formatTime: (d) ->
      minZero = if d.getMinutes() < 10 then '0' else ''
      "#{d.getHours()}:#{minZero}#{d.getMinutes()}"

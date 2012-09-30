_ = require 'web/js/lib/underscore'

validTransportTypes = ['bus', 'metro', 'train', 'tram', 'ferry']

respond = (req, code) ->
  req.response.statusCode = code
  req.response.end()

isValidTransportTypes = (types) ->
  if !types or types.length == 0
    return false
  else if types is 'all'
    return true
  else if _.intersection(types.split('|'), validTransportTypes).length is types.split('|').length
    return true
  false

module.exports =

  validateGetAddress: (handler) ->
    (req) ->
      if /^\d+\.\d+,\d+\.\d+$/.test(req.params().coords)
        handler req
      else
        respond req, 400

  validateAutocomplete: (handler) ->
    (req) ->
      qry = req.params().query
      if qry? and qry.length > 0
        if qry.length < 100
          handler req
        else
          respond req, 413
      else
        respond req, 400

  validateGetRoutes: (handler) ->
     (req) ->
      params = req.params()
      if !params.from? || params.from.length is 0 || !params.to? || params.to.length is 0
        respond req, 400
      else if params.from.length > 100 or params.to.length > 100
        respond req, 413
      else if !/^\d{8}$/.test(params.date)
        respond req, 400
      else if !/^\d{4}$/.test(params.time)
        respond req, 400
      else if !isValidTransportTypes(params.transportTypes)
        respond req, 400
      else if params.arrivalOrDeparture isnt 'departure' and params.arrivalOrDeparture isnt 'arrival'
        respond req, 400
      else
        handler req

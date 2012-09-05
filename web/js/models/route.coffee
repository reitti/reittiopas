define ['jquery', 'underscore', 'backbone', 'utils'], ($, _, Backbone, Utils) ->

  class Route extends Backbone.Model

    @find: (from, to, callback) ->
      params = $.param {from: from, to: to}
      $.getJSON "/routes?#{params}", (data) ->
        callback(new Route(routeData[0]) for routeData in data)

    departureTime: ->
      Utils.parseDateTime _.first(_.first(@get('legs')).locs).arrTime

    arrivalTime: () ->
      Utils.parseDateTime _.last(_.last(@get('legs')).locs).arrTime

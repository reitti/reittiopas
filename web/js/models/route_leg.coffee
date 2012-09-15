define ['underscore', 'backbone', 'utils'], (_, Backbone, Utils) ->

  class RouteLeg extends Backbone.Model

    firstArrivalTime: ->
      @get('firstArrivalTime') or Utils.parseDateTime _.first(@get('locs')).arrTime

    lastArrivalTime: ->
      @get('lastArrivalTime') or Utils.parseDateTime _.last(@get('locs')).arrTime

    lineName: () ->
      switch @get('type')
        when 'walk', '7' then '&nbsp;'                   # Walking, ferry -> no code
        when '6' then 'M'                                # Metro -> 'M'
        when '12' then @get('code').substring(4, 5)      # Commuter trains -> Character only
        when 'pre_departure', 'post_arrival' then ''    
        else                                             # Anything else -> number + possible character
          n = parseInt(@get('code').substring(1, 4), 10)
          chr = @get('code').substring(4, 5)
          "#{n}#{chr}"

    destinationName: () ->
      _(@get('locs')).last()?.name

    duration: () ->
      Utils.getDuration @firstArrivalTime(), @lastArrivalTime()

    preDepartureTime: () ->
      "+#{Utils.formatDuration(@duration())}"

    postArrivalTime: () ->
      "-#{Utils.formatDuration(@duration())}"

    isWalk: () -> @get('type') is 'walk'
    isPreDeparture: () -> @get('type') is 'pre_departure'
    isPostArrival: () -> @get('type') is 'post_arrival'
    isFiller: () -> @isPreDeparture() or @isPostArrival()


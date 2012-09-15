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
        when 'pre_departure' then @preDepartureTime()    # Pre-departure -> Show the time
        when 'post_arrival' then ''                      # Post-arrival -> Show nothing
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


    isWalk: () -> @get('type') is 'walk'
    isFiller: () -> @get('type') is 'pre_departure' or @get('type') is 'post_arrival'


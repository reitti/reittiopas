define ['underscore', 'backbone', 'utils'], (_, Backbone, Utils) ->

  class RouteLeg extends Backbone.Model

    firstArrivalTime: ->
      Utils.parseDateTime _.first(@get('locs')).arrTime

    lastArrivalTime: ->
      Utils.parseDateTime _.last(@get('locs')).arrTime

    lineName: () ->
      switch @get('type')
        when 'walk', '7' then '&nbsp;'                   # Walking, ferry -> no code
        when '6' then 'M'                                # Metro -> 'M'
        when '12' then @get('code').substring(4, 5)      # Commuter trains -> Character only
        else                                             # Anything else -> number + possible character
          n = parseInt(@get('code').substring(1, 4), 10)
          chr = @get('code').substring(4, 5)
          "#{n}#{chr}"

    destinationName: () ->
      _(@get('locs')).last()?.name

    isWalk: () -> @get('type') is 'walk'

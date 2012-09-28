define ['underscore', 'backbone', 'utils'], (_, Backbone, Utils) ->

  class RouteLeg extends Backbone.Model

    firstArrivalTime: ->
      @get('firstArrivalTime') or Utils.parseDateTimeFromMachines _.first(@get('locs')).arrTime

    lastArrivalTime: ->
      @get('lastArrivalTime') or Utils.parseDateTimeFromMachines _.last(@get('locs')).arrTime

    lineName: () ->
      switch @get('type')
        when 'walk', '7' then '&nbsp;'                   # Walking, ferry -> no code
        when '6' then 'M'                                # Metro -> 'M'
        when '12' then @get('code').substring(4, 5)      # Commuter trains -> Character only
        else                                             # Anything else -> number + possible character
          n = parseInt(@get('code').substring(1, 4), 10)
          chr = @get('code').substring(4, 5)
          "#{n}#{chr}"

    setOrigin: (name, coords) ->
      @get('locs').unshift(name: name, loc: coords, arrTime: _.first(@get('locs')).arrTime)
      @get('shape').unshift coords

    setDestination: (name, coords) ->
      @get('locs').push(name: name, loc: coords, arrTime: _.last(@get('locs')).arrTime)
      @get('shape').push coords

    originName: () ->
      _(@get('locs')).first()?.name

    destinationName: () ->
      _(@get('locs')).last()?.name

    duration: () ->
      Utils.getDuration @firstArrivalTime(), @lastArrivalTime()

    isWalk: () -> @get('type') is 'walk'


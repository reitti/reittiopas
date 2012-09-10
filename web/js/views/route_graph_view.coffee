define ['backbone', 'utils', 'handlebars', 'hbs!template/route_graph'], (Backbone, Utils, Handlebars, template) ->

  class RouteGraphView extends Backbone.View

    events:
      'click li': 'expand'

    initialize: (routes: routes, index: index) ->
      @routes = routes
      @index = index
      @route = routes.getRoute(@index)

    render: ->
      @$el.html template
        legs: @_legData()
      @$el.toggleClass 'not-expanded'
      this

    expand: (evt) =>
      if @route.getLegCount() > 1
        @$el.toggleClass 'expanded'
        @$el.toggleClass 'not-expanded'

    _legData: () ->
      cumulativePercentage = @routes.getDurationPercentageBeforeDeparture(@index)
      for leg,legIdx in @route.get('legs')
        percentage = @routes.getLegDurationPercentage(@index, legIdx)
        cumulativePercentage += percentage

        percentBefore = cumulativePercentage - percentage
        percentAfter = 95 - cumulativePercentage
        infoMap = @_legInfoLayoutMap(leg, legIdx, percentBefore, percentAfter)

        _.extend infoMap,
          type: leg.get('type')
          indicator: if leg.isWalk() then "" else leg.lineName()
          firstArrivalTime: Utils.formatTime(leg.firstArrivalTime())
          transportType: @_transportLabel(leg)
          destinationName: @_destinationLabel(leg, legIdx)
          color: Utils.transportColors[leg.get('type')]
          percentage: percentage
          percentageBefore: percentBefore
          percentageAfter: percentAfter
          iconVisible: percentage > 4

    _legInfoLayoutMap: (leg, legIdx, percentBefore, percentAfter) ->
      time = @_timeLabel(leg)
      transport = @_transportLabel(leg)
      arrow = "&rarr;"
      dest = @_destinationLabel(leg, legIdx)

      result = {}
      if percentBefore >= 40
        result.outerLeft = [time, transport, arrow, dest]
      else if percentAfter >= 40
        result.outerRight = [time, transport, arrow, dest]
      else if percentBefore >= 30
        result.outerLeft = [time, transport, arrow, dest]
      else if percentAfter >= 30          
        result.outerRight = [time, transport, arrow, dest]
      else if percentBefore >= 20 and percentAfter >= 20
        result.outerLeft= [time, transport]
        result.outerRight = [dest]
      else
        result.innerLeft = [time, transport]
        result.innerRight = [dest]
      result

    _legInfoLabel: (leg, legIdx) ->
      new Handlebars.SafeString(
        legInfoTemplate
          time: Utils.formatTime(leg.firstArrivalTime())
          transport: @_transportLabel(leg)
          destination: @_destinationLabel(leg,legIdx)
      )

    _timeLabel: (leg) ->
      Utils.formatTime(leg.firstArrivalTime())

    _destinationLabel: (leg, legIdx) ->
      if legIdx is @route.getLegCount() - 1
          to = @route.get('to')
          cityIdx = to.lastIndexOf(',')
          if cityIdx < 0 then to else to.substring(0, cityIdx)
       else
         leg.destinationName()

    _transportLabel: (leg) ->
      type = leg.get('type')
      content = switch type
        when 'walk' then "#{@_transportTypeLabel(type)} (#{Utils.formatDistance(leg.get('length'))})"
        when '6','7' then @_transportTypeLabel(type)
        when '12' then "#{leg.lineName()}-#{@_transportTypeLabel(type)}"
        else "#{@_transportTypeLabel(type)} #{leg.lineName()}"
      new Handlebars.SafeString "<strong>#{content}</strong>"

    # TODO: This should be somewhere in i18n
    _transportTypeLabel: (type) ->
      switch type
        when 'walk' then 'kävely'
        when '2' then "ratikka"
        when '6' then "metro"
        when '7' then "lautta"
        when '12' then "juna"
        else "bussi"

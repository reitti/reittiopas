define ['underscore', 'backbone', 'utils', 'handlebars', 'hbs!template/route_graph'], (_, Backbone, Utils, Handlebars, template) ->

  class RouteGraphView extends Backbone.View

    events:
      'click .transport-link': 'selectLeg'

    initialize: (routes: routes, index: index) ->
      @routes = routes
      @index = index
      @route = routes.at(@index)
      Reitti.Event.on 'route:change', @onRouteChanged

    dispose: ->
      Reitti.Event.off 'route:change', @onRouteChanged

    render: ->
      @$el.html template(legs: @_legData())
      this

    selectLeg: (e) =>
      idx = $(e.target).closest('[data-leg]').data('leg')
      Reitti.Event.trigger 'leg:change', @route.getLeg(idx)
      false

    onRouteChanged: (route) =>
      return if @route.getLegCount() <= 1 
      isThis = route is @route
      _.defer =>
        @$el.toggleClass 'expanded', isThis
        @$el.css 'height', if isThis then "#{@route.getLegCount() * 24}px" else ''
        @$el.find('li[data-leg]').each ->
          if isThis
            legNr = $(this).data 'leg'
            top = legNr * 24
            $(this).css 'top', "#{top}px"
          else
            $(this).css 'top', '0'


    _legData: () ->
      cumulativePercentage = 0
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
          percentageBeforeAndDuring: percentBefore + percentage
          percentageAfter: percentAfter
          iconVisible: percentage > 5

    _legInfoLayoutMap: (leg, legIdx, percentBefore, percentAfter) ->
      time = @_timeLabel(leg)
      transport = @_transportLabel(leg)
      arrow = "&rarr;"
      dest = @_destinationLabel(leg, legIdx)

      if leg.isFiller()
        return {outerRight: [transport]}


      result = {}
      if percentBefore >= 40
        result.outerLeft = [time, transport, arrow, dest]
      else if percentAfter >= 40
        result.outerRight = [time, transport, arrow, dest]
      else if percentBefore >= 30
        result.outerLeft = [time, transport, arrow, dest]
      else if percentAfter >= 30          
        result.outerRight = [time, transport, arrow, dest]
      else if percentBefore >= 15 and percentAfter >= 15
        result.outerLeft= [time, transport]
        result.outerRight = [arrow, dest]
      else
        result.innerLeft = [time, transport]
        result.innerRight = [arrow, dest]
      result

    _timeLabel: (leg) ->
      "#{Utils.formatTime(leg.firstArrivalTime())}-#{Utils.formatTime(leg.lastArrivalTime())}"

    _destinationLabel: (leg, legIdx) ->
      if leg is @route.getLastLegBeforeArrival()
          to = @routes.to
          cityIdx = to.lastIndexOf(',')
          if cityIdx < 0 then to else to.substring(0, cityIdx)
       else
         leg.destinationName()

    _transportLabel: (leg) ->
      type = leg.get('type')
      content = switch type
        when 'walk' then "#{@_transportTypeLabel(type)}, #{Utils.formatDistance(leg.get('length'))}"
        when '6','7' then @_transportTypeLabel(type)
        when '12' then "#{leg.lineName()}-#{@_transportTypeLabel(type)}"
        else "#{@_transportTypeLabel(type)} #{leg.lineName()}"
      new Handlebars.SafeString "<a class='transport-link' href='#'>#{content}</a>"

    # TODO: This should be somewhere in i18n
    _transportTypeLabel: (type) ->
      switch type
        when 'walk' then 'kävely'
        when 'pre_departure', 'post_arrival' then ''
        when '2' then "ratikka"
        when '6' then "metro"
        when '7' then "lautta"
        when '12' then "juna"
        else "bussi"


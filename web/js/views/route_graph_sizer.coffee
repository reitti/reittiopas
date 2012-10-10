define ['utils'], (Utils) ->

  excessSize = (routes, index, availableSize, minimumSize) ->
    size = 0
    for leg, legIdx in routes.at(index).get('legs')
      preferredSize = routes.getLegDurationPercentage(index, legIdx) / 100 * availableSize
      if preferredSize < minimumSize
        size += minimumSize
      else
          size += preferredSize
    size - availableSize


  (routes, index, availableSize, minimumSize) ->
    route = routes.at(index)
    longestLeg = route.longestLeg()
    cumulativeSize = 0
    for leg, legIdx in route.get('legs')
      preferredSize = routes.getLegDurationPercentage(index, legIdx) / 100 * availableSize
      size = if preferredSize < minimumSize
          minimumSize
      else
        unless leg is longestLeg then preferredSize else preferredSize - excessSize(routes, index, availableSize, minimumSize)
      sizeBefore = cumulativeSize
      cumulativeSize += size
      {
        size: Utils.toPercentage(size / availableSize)
        sizeBefore: Utils.toPercentage(sizeBefore / availableSize)
      }
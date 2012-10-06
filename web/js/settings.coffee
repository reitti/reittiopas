define ->
  class Settings

    get: (key) ->
      if @_isLocalStorageSupported()
        JSON.parse(window.localStorage.getItem(key))

    set: (key, value) ->
      if @_isLocalStorageSupported()
        window.localStorage.setItem(key, JSON.stringify(value))
      value

    _isLocalStorageSupported: () ->
      try
        window.localStorage isnt null
      catch e
        false

define ['modernizr'], (Modernizr) ->
  class Settings

    get: (key) ->
      if Modernizr.localstorage
        JSON.parse(window.localStorage.getItem(key))

    set: (key, value) ->
      if Modernizr.localstorage
        window.localStorage.setItem(key, JSON.stringify(value))
      value
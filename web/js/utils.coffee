define ->
  class Utils

    @isLocalStorageEnabled: -> 
      typeof(Storage) isnt "undefined"


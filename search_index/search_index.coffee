load 'vertx.js'

class Node
  constructor: (@prefix) ->
    @children = {}
    
  ensure: (ch) ->
    @children[ch.toLowerCase()] ?= new Node(@prefix + ch)
    
  get: (ch) ->
    @children[ch]
    
  putMatches: (to, n) ->
    if @name?
      to.push {name: @name, coords: @loc}
      n -= 1
    for own ch,child of @children
      return 0 if n <= 0
      n = child.putMatches(to, n)
    n
      
      
class Trie
  constructor: () ->
    @root = new Node('')
  
  add: (place, city, loc) ->
    name = "#{place.trim()}, #{city.trim()}"
    placeParts = place.split /\s/
    for idx in [placeParts.length - 1..0]
      str = placeParts[idx..placeParts.length - 1].join(' ')
      @build "#{str.trim()}, #{city.trim()}", name, loc

  build: (str, name, loc) ->
    node = @root
    for i in [0...str.length]
      node = node.ensure(str.charAt(i))
    node.loc = loc
    node.name = name
    
  find: (str, max) ->
    node = @root
    for i in [0...str.length]
      node = node.get(str.charAt(i))
      return [] unless node?
    results = []
    node.putMatches results, max
    results
    
    
trie = new Trie
eb = vertx.eventBus

# Make yourself available via the event bus
eb.registerHandler 'reitti.searchIndex.find', ({query}, replier) ->
  replier {results: trie.find(query.toLowerCase(), 10)}
  
# Index all the resource files into the trie
files =
  'Espoo': 'search_index/data/espoo.txt'
  'Helsinki': 'search_index/data/helsinki.txt'
  'Kauniainen': 'search_index/data/kauniainen.txt'
  'Kerava': 'search_index/data/kerava.txt'
  'Kirkkonummi': 'search_index/data/kirkkonummi.txt'
  'Vantaa': 'search_index/data/vantaa.txt'

verySpecialPlaces =
  'Eficode, Helsinki': '24.947197,60.196284'
  'Piritori, Helsinki': '24.960712,60.18797'

for own city, f of files
  do (city, f) ->
    vertx.fileSystem.readFile f, (err, res) ->
      if err
        stdout.println err
      else
        lines = res.getString(0, res.length(), 'UTF-8').split '\n'
        for line in lines
          [place, loc] = line.split '|'
          loc = if loc? and loc?.length > 0 then loc else undefined
          trie.add(place, city, loc)

for own place, loc of verySpecialPlaces
  [thePlace, theCity] = place.split ','
  trie.add thePlace, theCity, loc



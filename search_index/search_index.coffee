load 'vertx.js'

class Node
  constructor: (@prefix) ->
    @children = {}
    
  ensure: (ch) ->
    @children[ch.toLowerCase()] ?= new Node(@prefix + ch)
    
  get: (ch) ->
    @children[ch]
    
  putMatches: (to, n) ->
    if @end
      to.push @prefix
      n -= 1
    for own ch,child of @children
      return 0 if n <= 0
      n = child.putMatches(to, n)
    n
      
      
class Trie
  constructor: () ->
    @root = new Node('')
  
  build: (str) ->
    node = @root
    for i in [0...str.length]
      node = node.ensure(str.charAt(i))
    node.end = true
    
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
eb.registerHandler 'reitti.searchIndex.find', (params, replier) ->
  replier {results: trie.find(params.query.toLowerCase(), 30)}
  
# Index all the resource files into the trie
files =
  'Espoo': 'search_index/data/espoo.txt'
  'Helsinki': 'search_index/data/helsinki.txt'
  'Kauniainen': 'search_index/data/kauniainen.txt'
  'Kerava': 'search_index/data/kerava.txt'
  'Kirkkonummi': 'search_index/data/kirkkonummi.txt'
  'Vantaa': 'search_index/data/vantaa.txt'

for own city, f of files
  do (city, f) ->
    vertx.fileSystem.readFile f, (err, res) ->
      if err
        stdout.println err
      else
        streets = res.getString(0, res.length(), 'UTF-8').split '\n'
        trie.build("#{street}, #{city}") for street in streets
  


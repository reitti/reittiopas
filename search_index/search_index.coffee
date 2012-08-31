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

eb.registerHandler 'reitti.searchIndex.find', (params, replier) ->
  replier {results: trie.find(params.query.toLowerCase(), 30)}
  
vertx.fileSystem.readFile 'search_index/streets.txt', (err, res) ->
  if err
    stdout.println err
  else
    streets = res.getString(0, res.length(), 'UTF-8').split '\n'
    trie.build(street) for street in streets

({
    appDir: 'web/',
    baseUrl: 'js/',
    dir: 'public',
    mainConfigFile: 'web/js/main.js',
    optimizeCss: 'standard.keepComments',
    inlineText: true,
    modules: [
        { name:'main', include: ['async', 'views/map_view', 'views/search_view'] }
    ]
})
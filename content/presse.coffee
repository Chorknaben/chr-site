class Presse extends ChildPage
    @ready = false
    @wall  = null
    constructor: ->
        super()

    onGenerateMarkup: ->

    onLoad: ->
        $.getScript "code/freewall.js", (data, textStatus, jqxhr) ->
            @ready = true
            wall   = new freewall(".presseart")
            wall.reset
                selector: '.brick'
                cellW: (container) -> 450
                    
                    #cellWidth = container / 3
                    #return cellWidth - 20 - ((0.12 * $(window).width()) / 3)
                    #console.log container
                    #cellWidth = 450
                    #if container.hasClass('s450')
                    #    cellWidth = container.width()/2
                    #return cellWidth
                cellH: (container) ->
                    cellHeight = container / 3
                    return cellHeight - 20
                    #cellHeight = 450
                    #if container.hasClass('s450')
                    #    cellHeight = container.height()/2
                    #return cellHeight
                fixSize: true
                gutterY: 20
                gutterX: 20
                animate: false
                onResize: ->
                    wall.fitWidth()
            wall.fitWidth()


    onScrollFinished: ->

    onUnloadChild: ->


window.core.insertChildPage(new Presse())

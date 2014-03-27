class Uberuns extends ChildPage
    constructor: ->

    onLoad: ->
        console.log "onLoad in here"
        #$(window).resize @verticallyCenterImage
        #$(window).resize()

    verticallyCenterImage: ->
        $img = $(".main-area img")
        wHeight = $(".main-area").outerHeight()

        if $img.height() < wHeight 
            delta = wHeight - $img.height()
            $img.css 'margin-top' : (delta / 2) + "px"
        else
            $img.attr 'style', ''

window.core.insertChildPage(new Uberuns())

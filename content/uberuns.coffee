class Uberuns extends ChildPage
    constructor: ->
        @core = window.core
        @oneshot = true

    onDOMVisible: ->

    notifyHashChange: (newHash) ->
        if @oneshot
            load = @core.requestFunction("Tile.load", (load) ->
                newHash = newHash.substr(1,newHash.length)
                load("Über uns", "uberuns-#{newHash}", true)
            , $.noop)
        @oneshot = false

    onLoad: ->
        $(".testblock").hover(->
            setTimeout( ->
                if $(".testblock").is(":hover")
                    $(".testblock").animate({opacity:0}, 350)
            , 700)
        ,->
            $(this).animate({opacity:1}, 350)
        )

        #$.getScript "code/sly.min.js", ->
        #    sly = new Sly(".uberuns-frame", {
        #        horizontal: 1
        #        itemNav:    'basic'
        #        #activateOn: 'click'
        #        mouseDragging: 1
        #        touchDragging: 1
        #        releaseSwing: 1
        #        smart: 1
        #        dynamicHandle: 1
        #        speed: 300
        #        easing: 'swing'
        #        scrollBy:   1
        #    }).init()
        #    #$(".presse-frame").css top: $(window).height()/2 - $(".presse-frame").height()/2
        window.core.release()

    mouseEnter: ->


window.core.insertChildPage(new Uberuns())

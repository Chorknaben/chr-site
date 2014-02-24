class Constants
    @SELECTOR_TILE = ".tile-content"
    @SELECTOR_NAV  = ".navitem nav"
    @tileResolver  = [
       ["Über uns", "uberuns"], ["Stiftung", "stiftung"],["Presse", "presse"],["Unterstützen","unterstutzen"],["Shop", "shop"],["Kalender", "cal"],["Bilder","bilder"] 
    ]

class Core
    bgSrc : "/#{ $(window).width() }/#{ $(window).height() - 90 }/"
    scrollHandlers: {}
    state:
        scrolledDown: false
        currentURL: "null"
        currentPage: "null"
    

    debug = (msg) -> console.log "Core: " + msg
        
    construct: ->
    handleHash: ->
        # If the site gets called and a hash is already set, for example when the
        # user has bookmarked a page and is now clicking on the bookmarked link,
        # trigger the corresponding tile onclick event
        if window.location.hash isnt ""
            debug "Hash detected"
            for i in [0..7]
                if "#" + Constants.tileResolver[i][1] is window.location.hash
                    i++
                    new Tile(i, Constants).onClick()
                    break

    injectBackground: ->
        # Determine the resolution of the client and send it to the server.
        # The server will return a matching background image.
        debug @bgSrc
        $ "<img>", src: @bgSrc + "bg"
            .appendTo($ "#bg").load ->
                #$(@).show()
                $(@).fadeIn 300
                #$("#bg").css("background-image": "url(#{@bgSrc}bg)")
                #       .fadeIn 300

    injectTileBackgrounds: ->
        # inject Tile Backgrounds as background attributes to the corresponding DOM
        # Elements.
        for i in [12..0]
            $("#" + i).css "background-image" : "url(#{@bgSrc + i})"
            tile = new Tile(i)
            $("#" + i).click (tile.onClick)

    loadEffects: ->
        stl = $( Constants.SELECTOR_TILE )

        stl.each (index, obj) ->
            obj = $ ( obj )
            obj.hover ->
                obj.children "a"
                   .children ".hoveroverlay"
                   .animate opacity:"0.7", 100
                $ stl.not(".hoveroverlay")[ index - 1 ]
                    .children ".hoveroverlay"
                    .animate opacity:"0", 100
            , ->
                obj.children "a"
                   .children ".hoveroverlay"
                   .animate opacity:"0", 100
                $ stl[ index - 1 ]
                    .children "a"
                    .children ".hoveroverlay"
                    .animate opacity:"0", 100

    getScrollHandler: (event) =>
        for key, val of @scrollHandlers
            val(event)

    registerScrollHandler: (name, callback) ->
        @scrollHandlers[name] = callback

    deleteScrollHandler: (name) ->
        for key in @scrollHandlers
            if key is name
                delete @scrollHandlers[key]


# Global Objects, associated to all other
# objects created due to the modular infrastructure
window.core = new Core
window.constants = Constants

$ ->
    # Important initialization code
    c = window.core
    c.handleHash()
    c.injectBackground()
    c.injectTileBackgrounds()
    c.loadEffects()
    $(window).scroll c.getScrollHandler

    # Basic functionality
    # -------------------

    # Handle changing the title back when the user is scrolling back up
    # from a child page
    c.registerScrollHandler "onTop", (event) ->
        if $(window).scrollTop() is 0 and $(".ctitle").html() isnt "St.-Martins-Chorknaben Biberach"
            setTimeout ->
                if $(window).scrollTop() is 0
                    window.location.hash = "#"
                    $(".ctitle").fadeTo(500, 0)
                    setTimeout ->
                        $(".ctitle").html("St.-Martins-Chorknaben Biberach")
                        $(".ctitle").fadeTo(200,1)
                    , 500
            , 1000

    # Handle scrolling upwards again after the user has visited a child page
    # note that this handler will sonn be unnecessary
    c.registerScrollHandler "scrollUpwards", (event) ->
        if $(window).scrollTop() < $(window).height() - 40 and c.state["scrolledDown"]
            $(".header-nav").fadeTo(200, 0)
            c.state["scrolledDown"] = false

    # This executes after the page has been fully loaded and is scrolled to
    # todo: maybe only load this handler when beginning to load a page / beginning
    # to scroll down etc as it is quite expensive
    c.registerScrollHandler "onLoadChild", (event) ->
        if $(window).scrollTop() > $(window).height() - 40 and not c.state["scrolledDown"]
            c.state["scrolledDown"] = true
            $(".header-nav").fadeTo(200,1)
            if c.state["currentURL"] isnt "null"
                window.location.hash = c.state["currentURL"]
            if c.state["currentPage"] isnt "null"
                $(".ctitle").fadeTo(200,0)
                setTimeout ->
                    $(".ctitle").html("Chorknaben // #{ c.state["currentPage"] }")
                      .fadeTo(200,1)
                , 200



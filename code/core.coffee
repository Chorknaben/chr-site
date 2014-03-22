class Constants
    @SELECTOR_TILE = ".tile-content"
    @SELECTOR_NAV  = ".navitem nav"
    @tileResolver  = [
       ["Über uns", "uberuns"], ["Stiftung", "stiftung"],["Presse", "presse"],["Musik","musik"],["Shop", "shop"],["Kalender", "kalender"],["Bilder","bilder"], ["Impressum", "impressum"]
    ]



class Core
    scrollHandlers: {}
    state: 
        scrolledDown : false
        currentURL   : "null"
        currentPage  : "null"
    

    debug = (msg) -> console.log "Core: " + msg
        
    construct: ->
    
    withAPICall: (url, callback) ->
        # Execute a Callback on an API call made to the server.
        # The Server always returns a valid JSON object, even when
        # a error occurs.
        $.ajax({
            url:url,
        })
          .done (data) ->
            callback(JSON.parse(data))

    initializeHashNavigation: ->
        # Initialize the hash
        if window.location.hash is ""
            window.location.hash = "#!/"

    handleHash: =>
        # If the site gets called and a hash is already set, for example when the
        # user has bookmarked a page and is now clicking on the bookmarked link,
        # trigger the corresponding tile onclick event
        if window.location.hash isnt "#!/"
            onlySoft = @requestTaker("softReload")
            if onlySoft
                @state["childPage"].onSoftReload()
                return
            debug "Hash detected"
            for i in [0..7]
                if "#!/" + Constants.tileResolver[i][1] is window.location.hash
                    i++
                    new Tile(i, Constants).onClick()
                    break


    getScrollHandler: (event) =>
        for key, val of @scrollHandlers
            val(event)

    registerScrollHandler: (name, callback) ->
        @scrollHandlers[name] = callback

    deleteScrollHandler: (name) ->
        for key in @scrollHandlers
            if key is name
                delete @scrollHandlers[key]

    executeOnce: (name, func) ->
        if @state["tmp" + name] is true
            return
        else
            @state["tmp" + name] = true
            func()

    rearm: (name) ->
        delete @state["tmp#{name}"]

    registerTaker: (name, obj) ->
        @state["taker#{name}"] = obj

    requestTaker: (name) ->
        s = @state["taker#{name}"]
        delete @state["taker#{name}"]
        return s

    insertChildPage: (pageObj) ->
        if @state["childPage"]
            @state["childPage"].onUnloadChild()
        @state["childPage"] = pageObj
        pageObj.onInsertion()

    exportFunction: (name, func) ->
        @state[name] = func

    requestFunction: (name, success, failure) ->
        func = @state[name]
        if func
            success(func)
        else
            failure()

    revokeFunction: (name) ->
        delete @state[name]

    #needed?
    #setIndexPage: (indexPage) ->

# Abstract Skeleton Class that any Child Page ought to execute.
class ChildPage
    constructor: ->
        # Associate with core object
        @c = window.core

    notImplemented = (name) ->
        console.log "#{name}: not implemented"

    # Any Markup that shall be generated with the aid
    # of ECMAScript has to be generated here. Other methods
    # do not guarantee that the markup has finished building
    # upon execution; this one does.
    onGenerateMarkup: ->
        notImplemented "onGenerateMarkup"

    # Executed once the Ajax Page has been successfully requested
    # from the server, but before the scrolling has initiated.
    # Please run computationally expensive operations in onScrollFinished,
    # not here, has the scrolling will lag when executing here.
    onLoad: ->
        notImplemented "onLoad"

    # Executed once the scrolling finished (800ms after starting to scroll).
    # This can be seen as an equivalent to $(document).ready(function(){...})
    onScrollFinished: ->
        notImplemented "onScrollFinished"

    # Executed when the user scrolls to the page again after having scrolled up.
    # This allows the Child Page to update its content without actually rebuilding
    # itself, creating an unpleasant user experience.
    onSoftReload: ->
        notImplemented "onSoftReload"

    # The User has begun to leave the page.
    onScrollUpwards: ->
        notImplemented "onScrollUpwards"

    # The Page is being unloaded in favor of a different one.
    # Please unload all Handlers registered into the core.
    onUnloadChild: ->
        notImplemented "onUnloadChild"

    # Executed immediately after insertion. Run time is quite equivalent to
    # own constructor execution.
    onInsertion: ->
        notImplemented "onInsertion"

class IndexPage extends ChildPage
    constructor: ->
        super()

    onInsertion: ->
        @injectBackground()
        @injectTileBackgrounds()
        @loadEffects()

    bgSrc : "/#{ $(window).width() }/#{ $(window).height() - 90 }/"

    injectBackground: ->
        # Determine the resolution of the client and send it to the server.
        # The server will return a matching background image.
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
        # attach hover effects to all tiles and navigation items
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

# Global Objects, associated to all other
# objects created due to the modular infrastructure
window.core = new Core
window.constants = Constants

$ ->
    # Important initialization code
    c = window.core
    c.initializeHashNavigation()
    c.handleHash()

    # Initial Page is the Index Page
    c.insertChildPage(new IndexPage())

    $(window).scroll c.getScrollHandler

    window.onhashchange = c.handleHash

    # Basic functionality
    # -------------------

    # Handle changing the title back when the user is scrolling back up
    # from a child page
    c.registerScrollHandler "onTop", (event) ->
        if $(window).scrollTop() is 0 and $(".ctitle").html() isnt "St.-Martins-Chorknaben Biberach"
            if $(window).scrollTop() is 0
                window.location.hash = "#!/"
                $(".ctitle").fadeTo(500, 0)
                setTimeout ->
                    $(".ctitle").html("St.-Martins-Chorknaben Biberach")
                    $(".ctitle").fadeTo(200,1)
                , 500

                # Also revert the Navigation Item that has slided to left
                navItems = $('.header-nav').children('a')
                
                # See tilec.coffee, because the calendar tile has no onclick (yet!)
                index = if c.state['tileid'] isnt 7 then c.state['tileid'] - 1 else 4

                ## The Calendar tile has no ScrollDown, so delegate to 
                ## big image tile
                underLineEl = $(navItems[index])
                underLineEl.css "font-weight" : "normal"

    # Handle scrolling upwards again after the user has visited a child page
    # note that this handler will sonn be unnecessary
    c.registerScrollHandler "scrollUpwards", (event) ->
        if $(window).scrollTop() < $(window).height() - 40 and c.state["scrolledDown"]
            #$(".header-nav").fadeTo(200, 0)
            # todo change to go down item
            c.state["scrolledDown"] = false

    # This executes after the page has been fully loaded and is scrolled to
    # todo: maybe only load this handler when beginning to load a page / beginning
    # to scroll down etc as it is quite expensive
    c.registerScrollHandler "onLoadChild", (event) ->
        if $(window).scrollTop() > $(window).height() - 40 and not c.state["scrolledDown"]
            c.state["scrolledDown"] = true
            # $(".header-nav").fadeTo(200,1)
            # todo change to go down item
            if (c.state["currentURL"] isnt "null") or ($(".ctitle").html() is "St.-Martins-Chorknaben Biberach")
                c.registerTaker("softReload", true)
                window.location.hash = "!/" + c.state["currentURL"]
                $(".ctitle").fadeTo(200,0)
                setTimeout ->
                    $(".ctitle").html("Chorknaben // #{ c.state["currentPage"] }")
                      .fadeTo(200,1)
                , 200

    $("#startst").click -> $.scrollTo('0px', 800)

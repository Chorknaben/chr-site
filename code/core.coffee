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
        if window.location.hash is "#!/" and @requestTaker("pageChanged")
            debug "Back to Index page"
            $(".tilecontainer").css display: "initial"
            $(".scrolled").css display: "none"
            @state["childPage"].onUnloadChild()
            @sanitize()


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

    sanitize: ->
        # sanitize is meant to be a general sanitization function.
        # Clean up UI-Fragments
        if window.location.hash is "#!/"
            $(".header-nav").children().each (i, obj) ->
                $obj = $(obj)
                console.log $obj.css("font-weight")
                if $obj.css("font-weight") is "bold"
                    $obj.css "font-weight" : "initial"

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

class Context
    #necessity unsure
    @internalState: {}
    constructor: (@pageName) ->
        @runDetection(@pageName)

    getCorrelations: ->
        return @internalState

    runDetection: (pageName) ->
        # Complete internalState using a limited
        # amount of clues



class IndexPage extends ChildPage
    constructor: ->
        super()
        w = $(window).width()
        if w > 1177
            @bgSrc = "/#{ $(window).width() }/#{ $(window).height() - 90 }/"
        else 
            @bgSrc = "/1610/#{$(window).height()-90}/"

    onInsertion: ->
        @injectBackground()
        @injectTileBackgrounds()
        @loadEffects()
        @preloadImage()
        @footerLeftClick()

    injectBackground: ->
        # Determine the resolution of the client and send it to the server.
        # The server will return a matching background image.
        $ "<img>", src: @bgSrc + "bg"
            .appendTo($ "#bg").load ->
                #$(@).show()
                $(@).fadeIn 300
                #$("#bg").css("background-image": "url(#{@bgSrc}bg)")
                #       .fadeIn 300

    preloadImage: ->
        img = new Image()
        w   = $(window).width()
        h   = $(window).height()
        src = "#{w}/#{h}/bg/blurred"
        img.src = src
        @c.state["blurredbg"] = img

        #$("<img>").attr("src", src)
        #    .css(position:"absolute", left:0, "z-index":-1)
        #    .prependTo("#infoarea")

    footerLeftClick: ->
        $(".footer-left").click (event) =>
            event.preventDefault()
            event.stopPropagation()
            @toggleInfo()

    toggleInfo: ->
        if $("#footer").css("bottom") is "0px"
            $("#footer").animate({bottom: "300px"}, 100)
            @rotateImg(".footer-left img", 180)
        else
            $("#footer").animate({bottom: "0px"}, 100)
            @rotateImg(".footer-left img", 0)


     rotateImg: (image, degree) ->
         $elem = $(image)
         $elem.css
             '-webkit-transform': 'rotate(' + degree + 'deg)',
             '-moz-transform': 'rotate(' + degree + 'deg)',
             '-ms-transform': 'rotate(' + degree + 'deg)',
             '-o-transform': 'rotate(' + degree + 'deg)',
             'transform': 'rotate(' + degree + 'deg)',
             'zoom': 1

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

class Navigation
    @preState = null
    constructor: ->



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

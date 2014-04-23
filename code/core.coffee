class Constants
    @SELECTOR_TILE = ".tile-content"
    @SELECTOR_NAV  = ".navitem nav"
    @METHODS = {
        "NAME" : 0x00001
        "NAME_USER" : 0x00010
        "ID" : 0x00100
    }
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
            dontHandle = @requestTaker("dontHandle")
            if dontHandle
                return
            debug "Hash detected"

            # Delegate the Hash if it belongs to a currently loaded childPage
            currentPage = $(".scrolled").attr("id")
            if currentPage
                unless window.location.hash.length is 3+currentPage.length
                    if window.location.hash.substr(3,currentPage.length) is currentPage
                        subHash = window.location.hash.substr(3+currentPage.length, window.location.hash.length)
                        @state["childPage"].notifyHashChange(subHash)
                        return
            else
                if window.location.hash.indexOf("/",2) isnt -1
                    console.log "this condition is true"
                    @registerTaker("backupHash", window.location.hash)
                    for i in [0..7]
                        if window.location.hash.indexOf(Constants.tileResolver[i][1]) isnt -1
                            i++
                            new Tile(i, Constants).onClick()
                            break
                    return

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
            window.nav.reset()

    executeOnce: (name, func) ->
        if @state["tmp" + name] is true
            return
        else
            @state["tmp" + name] = true
            func()

    rearm: (name) ->
        delete @state["tmp#{name}"]

    registerTaker: (name, obj) ->
        @state["__taker#{name}"] = obj

    requestTaker: (name) ->
        s = @state["__taker#{name}"]
        delete @state["__taker#{name}"]
        return s

    insertChildPage: (pageObj) ->
        if @state["childPage"]
            @state["childPage"].onUnloadChild()
        @state["childPage"] = pageObj
        pageObj.onInsertion()

    exportFunction: (name, func) ->
        @state[name] = func

    requestFunction: (name, success, failure=$.noop) ->
        func = @state[name]
        if func
            success(func)
        else
            failure()

    revokeFunction: (name) ->
        delete @state[name]

    release: ->
        @requestFunction("Tile.finalizeLoading",
            (func) -> func())

# Abstract Skeleton Class that any Child Page ought to execute.
class ChildPage
    constructor: ->
        # Associate with core object
        @c = window.core

    notImplemented = (name) ->
        console.log "#{name}: not implemented"

    # Executes when the DOM is visible, and thus the elements are positioned
    # correctly on the users screen.
    onDOMVisible: ->
        notImplemented "onDOMVisible"

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

    # When Childpage returns true, the core will continue to show the loading
    # screen until the Childpage interrupt the core with .release()
    acquireLoadingLock: ->
        return false

    # An Hash is being delegated to the subpage
    notifyHashChange: (newHash) ->


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

        @currentRotatorImgID = 0
        @maxRotatorImgID = 100
        @imgObj = null

    onInsertion: ->
        @injectBackground()
        @injectTileBackgrounds()
        @loadEffects()
        @preloadImage()
        @footerLeftClick()
        @imgRotator(10000)

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

    imgRotator: (waitFor) ->
        #@currentRotatorImgID = 0
        #@maxRotatorImgID = 100
        #
        if @currentRotatorImgID is 0
            console.log "imgRotator: init"
            @makeImage(->
                $("#link-bilder").append(@imgObj))
            @imgRotator(15000)
        else
            console.log "imgRotator: now:wait"
            setTimeout(=>
                $("#link-bilder img").addClass("luminanz")
                setTimeout(=>
                    console.log "after fade"
                    $("#link-bilder img").remove()
                    if @currentRotatorImgID > @maxRotatorImgID
                        @currentRotatorImgID = 1
                    @makeImage((image) =>
                        setTimeout(=>
                            console.log image
                            $("#link-bilder").append(image)
                            $(image).removeClass("luminanz")
                            setTimeout(=>
                                @imgRotator(15000)
                            ,2000)
                        , 3000)
                    , true)
                , 2000)
            , waitFor)

    makeImage: (onload,lum) ->
        @imgObj = new Image()
        @imgObj.onload = onload(@imgObj)
        @imgObj.src = "/images/real/#{@currentRotatorImgID}"
        if lum then @imgObj.classList.add("luminanz")
        @currentRotatorImgID++

     luminanz: (image, saturate, opacity) ->
         $elem = $(image)
         $elem.css
             '-webkit-filter': "saturate(#{saturate}) opacity(#{opacity})",
             '-moz-filter': "saturate(#{saturate}) opacity(#{opacity})",
             '-ms-filter': "saturate(#{saturate}) opacity(#{opacity})",
             '-o-filter': "saturate(#{saturate}) opacity(#{opacity})",
             'filter': "saturate(#{saturate}) opacity(#{opacity})",

    injectTileBackgrounds: ->
        # inject Tile Backgrounds as background attributes to the corresponding DOM
        # Elements.
        for i in [12..0]
            $("#" + i).css "background-image" : "url(#{@bgSrc + i})"

    loadEffects: ->
        # attach hover effects to all tiles and navigation items
        stl = $( Constants.SELECTOR_TILE )

        #stl.each (index, obj) ->
        #    obj = $ ( obj )
        #    obj.hover ->
        #        obj.children "a"
        #           .children ".hoveroverlay"
        #           .animate opacity:"0.7", 100
        #        $ stl.not(".hoveroverlay")[ index - 1 ]
        #            .children ".hoveroverlay"
        #            .animate opacity:"0", 100
        #    , ->
        #        obj.children "a"
        #           .children ".hoveroverlay"
        #           .animate opacity:"0", 100
        #        $ stl[ index - 1 ]
        #            .children "a"
        #            .children ".hoveroverlay"
        #            .animate opacity:"0", 100

class Navigation
    @preState = null
    constructor: (element) ->
        @navigator = $(element)
        console.log @navigator
        @navigationChilds = @navigator.children()

    by: (method, name) ->
        if method is Constants.METHODS.NAME
            result = null
            @navigationChilds.each (i, obj) ->
                href = obj.attributes["href"].firstChild
                if href.data.substring(3, href.length) is name
                    result = $(obj)
                    return false
            if result is null
                throw new Error("No such name under method")
            @internalToggle(result)
        else if method is Constants.METHODS.ID
            if 0 > name > @navigationChilds.length
                throw new Error("No object with this ID")
            result = $(@navigationChilds[name])
            @internalToggle(result)

    reset: ->
        if @preState isnt undefined
            @preState.css "font-weight" : "initial"

    internalToggle: (toggleThis) ->
        console.log @preState
        if @preState isnt undefined
            @preState.css "font-weight" : "initial"
        toggleThis.css    "font-weight" : "bold"
        @preState = toggleThis




# Global Objects, associated to all other
# objects created due to the modular infrastructure
window.core = new Core
window.constants = Constants

$ ->
    window.nav = new Navigation(".header-nav")

    # Important initialization code
    c = window.core
    c.initializeHashNavigation()
    c.handleHash()

    # Initial Page is the Index Page
    c.insertChildPage(new IndexPage())

    $(window).scroll c.getScrollHandler

    window.onhashchange = c.handleHash

class Constants
    @SELECTOR_TILE = ".tile-content"
    @SELECTOR_NAV  = ".navitem nav"
    @METHODS = {
        "NAME" : 0x00001
        "NAME_USER" : 0x00010
        "ID" : 0x00100
    }
    #Subpages first; order important
    @ApplicationRoutes = [
          ["uberuns/reise", "uberuns-reise"]
        , ["uberuns/team", "uberuns-team"]
        , ["uberuns/timeline", "uberuns-timeline"]
        , ["uberuns", "uberuns"]
        , ["stiftung", "stiftung"]
        , ["presse", "presse"]
        , ["musik","musik"]
        , ["shop", "shop"]
        , ["kalender", "kalender"]
        , ["bilder","bilder"]
        , ["impressum", "impressum"]
        , ["unterstutzen", "unterstutzen"]
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
        # Respond to a hash change.
        if @state["globalHashResponseDisabled"]
            return

        hash = window.location.hash

        @ensureFooterDown()


        if hash is "#!/"
            @raiseIndexPage()
            return

        # Top priority: test if Hash can be resolved to a route.
        # Only the relevant part, that is, everything after #!/ will
        # be tested for being a route.
        #   Then, if the hash is a valid route, matching.msg will return "match"
        #   If it isn't, it will return "nomatch"
        matching = @resolveLocator(hash)
        switch matching.msg
            when "match"
                # Then, in "match" it will be checked if the site is already loaded.
                # If so, 
                #   If there is a remaining part of the hash
                #       Delegate this Hash to the child page
                # Else,
                #   Actually load the child page.
                #   Then,
                #       If there is a remaining part of the hash
                #       Delegate this Hash to the child page
                matching.handler()
                return
            when "nomatch"
                # Display a 404; stub!
                matching.handler()
                return

    resolveLocator: (hash) =>
        # strip preceding junk
        route = null
        usefulHash = hash.substr(3, hash.length)
        for element in Constants.ApplicationRoutes
            # usefulhash.startsWith(element)
            if usefulHash.lastIndexOf(element[0], 0) is 0
                route = element[1]
                break
        if route
            return {
                msg: "match"
                handler: =>
                    if $(".scrolled").attr("id") is route
                        # Child page is already loaded
                        @delegateChildPage(route, usefulHash)
                    else
                        #@ensureImageViewerClosed()
                        @requestFunction "Tile.load", (load) =>
                            load route, =>
                                @delegateChildPage(route, usefulHash)
            }

        else
            return {
                msg: "nomatch"
                handler: =>
                    console.log "fixme: display 404"
            }

    delegateChildPage: (route, hash) ->
        # delegate the route part
        delegatePart = hash.substr(route.length, hash.length)
        @state["childPage"].notifyHashChange(delegatePart)

    raiseIndexPage: ->
        if window.location.hash is "#!/" and @requestTaker("pageChanged")
            debug "Back to Index page"

            #@ensureImageViewerClosed()

            $(".tilecontainer").css display: "initial"
            $(".scrolled").css display: "none"
            $(".scrolled").attr("id", "")

            @state["childPage"].onUnloadChild()
            @state["childPage"] = new IndexPage()
            @state["currentPage"] = undefined
            @state["currentURL"] = undefined

            window.nav.reset()

            @requestFunction("ImgRotator.pauseImgRotator", (func) -> 
                console.log "imgRotator: resume"
                func(true))
        else
            debug "Already at Index Page"

    ensureFooterDown: ->
        $("#footer").css bottom: "0px"

    ensureImageViewerClosed: ->
        @requestFunction "ImageViewer.forceClose",
            (func) => 
                func(true)
        @revokeFunction "ImageViewer.forceClose"


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
        @requestFunction("ImgRotator.pauseImgRotator", (func) ->
            func(false))
        pageObj.onInsertion()

    exportFunction: (name, func) ->
        @state[name] = func

    requestFunction: (name, success, failure=$.noop) ->
        func = @state[name]
        if func
            success(func)
        else
            console.log failure
            console.log $.noop
            failure()

    revokeFunction: (name) ->
        delete @state[name]

    release: ->
        @requestFunction("Tile.finalizeLoading",
            (func) -> func())

        callback = @requestTaker("pendingCallback")
        if callback then callback()

# Abstract Skeleton Class that any Child Page ought to implement
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
        @currentNewsID = 0
        @maxRotatorImgID = 100
        @imgObj = null
        @imgRotatorEnabled = true
        @navDropDown = false

        @contentViewer = @c.requestFunction "ContentViewer.requestInstance", 
            (cView) => @contentViewer = cView()

    onInsertion: ->
        @injectBackground()
        @injectTileBackgrounds()
        @preloadImage()
        @footerLeftClick()
        @initNavDropDown()
        @initNewsRotator()
        @initKalender()
        @imgRotator(10000)

        @c.exportFunction("ImgRotator.pauseImgRotator", @pauseImgRotator)

    injectBackground: ->
        # Determine the resolution of the client and send it to the server.
        # The server will return a matching background image.
        $ "<img>", src: @bgSrc + "bg"
            .load ->
                $(@).appendTo("#bg")

    preloadImage: ->
        img = new Image()
        w   = $(window).width()
        h   = $(window).height()
        src = "#{w}/#{h}/bg/blurred"
        img.src = src
        @c.state["blurredbg"] = img

    footerLeftClick: ->
        $(".footer-left").click (event) =>
            event.preventDefault()
            event.stopPropagation()
            @toggleInfo()

        $("#btnimpressum").click (event) =>
            event.preventDefault()
            event.stopPropagation()
            @toggleImpressum()

        $("#startst").click =>
            $("#footer").css bottom: "0px"

    toggleInfo: ->
        bot = $("#footer").css("bottom")
        if bot isnt "300px" and bot isnt "0px"
            # not open
            @toggleImpressum()
            setTimeout( =>
                @toggleInfo()
            , 310)
        if $("#footer").css("bottom") is "0px"
            $("#feedback").addClass("nodisplay")
            $("#infoarea").removeClass("nodisplay")
            $("#footer").css bottom: "300px"
        else
            $("#footer").css bottom: "0px"

    toggleImpressum: ->
        # TODO already pressed
        if $("#footer").css("bottom") is "300px"
            @toggleInfo()
            setTimeout( =>
                @toggleImpressum()
            , 320)

        to = $(window).height() - 50 - 25
        if $("#footer").css("bottom") is "0px"
            $("#feedback").removeClass("nodisplay")
            $("#feedback").css height: to + 1
            $("#infoarea").addClass("nodisplay")
            $("#footer").css bottom: to
        else
            $("#footer").css bottom: "0px"

    imgRotator: (waitFor) ->
        if @currentRotatorImgID is 0
            console.log "imgRotator: init"
            @makeImage(->
                $("#link-bilder").append(@imgObj))
            @imgRotator(15000)
        else
            #TODO gradual transfer
            setTimeout(=>
                $("#link-bilder img").addClass("luminanz")
                setTimeout(=>
                    $("#link-bilder img").remove()
                    if @currentRotatorImgID > @maxRotatorImgID
                        @currentRotatorImgID = 1
                    @makeImage((image) =>
                        $("#link-bilder").append(image)
                        @imgRotator(15000)
                    , false)
                , 2000)
            , waitFor)

    initNewsRotator: ->
        $.getJSON "newsticker.json", (data) =>
            @news = data.news
            @newsRotator(7500)

    newsRotator: (waitFor) ->
        if @currentNewsID is 0
            console.log "newsRotator: init"
            $(".right").children("p").html("+++ #{@news[0]} +++")
            $(".right").children("p").css opacity: 1
            @currentNewsID++
            @newsRotator(waitFor)
            
        else
            setTimeout(=> 
                $(".right").children("p").css opacity:0
                setTimeout(=>
                    $(".right").children("p").html("+++ #{@news[@currentNewsID]} +++")
                    $(".right").children("p").css opacity: 1
                    if @currentNewsID >= @news.length
                        @currentNewsID = 0
                    else @currentNewsID++
                    @newsRotator(waitFor)
                , 1000)
            , waitFor)


    pauseImgRotator: (state) =>
        @imgRotatorEnabled = state

    makeImage: (onload,lum) ->
        @imgObj = new Image()
        @imgObj.onload = =>
            onload(@imgObj)
        @imgObj.src = "/images/real/#{@currentRotatorImgID}"
        if lum then @imgObj.classList.add("luminanz")
        if @imgRotatorEnabled then @currentRotatorImgID++

    injectTileBackgrounds: ->
        # inject Tile Backgrounds as background attributes to the corresponding DOM
        # Elements.
        for i in [12..0]
            $("#" + i).css "background-image" : "url(#{@bgSrc + i})"

    initNavDropDown: ->
        nav = $(".header-nav-dropdown")
        $(".header-nav-dropdown-icon").click =>
            if not @navDropDown
                console.log "enter"
                nav.css top: "50px"
                @navDropDown = true
                @ignoreFirstShot = true
                $(document).on("click.nav", @leaveNavDropDown)
            else
                console.log "leave"
                @leaveNavDropDown()

    leaveNavDropDown: =>
        if @ignoreFirstShot
            @ignoreFirstShot=false
            return
        console.log "leave"
        $(".header-nav-dropdown").css top: "-200px"
        @navDropDown = false
        $(document).off("click.nav")


    initKalender: ->
        pos = $("#6").offset()
        $("#6").click (event) =>
            @contentViewer.open
                left:   -> $(window).width() * 0.06
                top:    -> $(".smalltiles").children().first().offset().top
                right:  -> $(window).width() * 0.06
                height: -> $(".bigtile-content").height() + 10 + 40
                chapter: false
                title: "Kalender"
                caption: "Konzerte, Gottesdienste, Grillparties"
                revertHash: "#!/"
                content: $(".kalendar").html()
                animate: true
                startingPos:
                    left: pos.left
                    top: pos.top
                    width: $("#6").width()
                    height: $("#6").height()
                    
                
            event.stopPropagation()
            event.preventDefault()

class Navigation
    @preState = null
    constructor: (element) ->
        @navigator = $(element)
        @navigationChilds = @navigator.children()

    by: (method, name) ->
        if method is Constants.METHODS.NAME
            result = null
            @navigationChilds.each (i, obj) ->
                href = obj.attributes["href"].value
                if href.substring(3, href.length) is name
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
        else if method is Constants.METHODS.NAME_USER
            result = null
            for element in @navigationChilds
                h = $(element).attr("href")
                if name.lastIndexOf(h.substr(3,h.length), 0) is 0
                    result = $(element)
                    break
            if result is null then result = @inDropdown(name)
            if result is null
                throw new Error("No object with such a internal name")
            @internalToggle(result)

    inDropdown: (name) ->
        nav = $(".header-nav-dropdown").children()
        result = null
        for element in nav
            el = $(element).children("a").attr("href")
            if name.lastIndexOf(el.substr(3, el.length), 0) is 0
                result = $(element)
                break
        return result

    reset: ->
        if @preState isnt undefined
            @preState.css "font-weight" : "initial"

    internalToggle: (toggleThis) ->
        console.log @preState
        if @preState isnt undefined
            @preState.css "font-weight" : "initial"
        toggleThis.css    "font-weight" : "bold"
        @preState = toggleThis


class ContentViewer
    constructor: ->
        @core = window.core
        @revertHash = null
        @left = null
        @right = null
        @top = null
        @height = -> "initial"

    open: (contentObj) =>
        $cnt = $(".content-viewer")
        #todo click another while open? think about that bitch..
        console.log "contentViewer: open"

        @revertHash = contentObj.revertHash
        @left = contentObj.left
        @right = contentObj.right
        @top = contentObj.top
        if contentObj.height
            @height = contentObj.height

        if contentObj.scrollTo
            $.scrollTo(contentObj.scrollTo.offset().top-contentObj.top(), 500)

        if contentObj.animate
            pos = contentObj.startingPos
            @clearPadding()
            $cnt.css 
                left: pos.left
                top: pos.top
                width: pos.width 
                height: pos.height
                background:"#1a171a"
            $cnt.removeClass("nodisplay")

            $cnt.css
                width: $(window).width() - @right() - @left()
                left: @left()
            setTimeout(=>
                $cnt.css
                    height: @height()
                    top: @top()
                @continue(contentObj, $cnt)
            , 200)
        else
            @continue(contentObj, $cnt)


    continue: (contentObj, $cnt) ->
        $("html").css cursor:"pointer"
        @update()

        $cnt.children("h1").html(contentObj.title)
        $cnt.children("h2").html(contentObj.caption)
        $cnt.children("#ccnt").html(contentObj.content)

        $(document).bind("click.content", @closeClickHandler)
        $(".content-viewer").bind("click.content", @clickOnViewerHandler)

        $cnt.removeClass("nodisplay")
        $(window).on("resize", @update)

    clearPadding: ->
        $(".content-viewer").css padding: 0

    setPadding: ->
        $(".content-viewer").css padding: "30px 50px 0 50px"
        

    update: =>
        $(".content-viewer").css
            left: @left()
            right: @right()
            top: @top()
            height: @height()

    close: (revertHash) =>
        $cnt = $(".content-viewer")
        console.log "contentViewer: close"

        $(document).unbind("click.content", @closeClickHandler)
        $(".content-viewer").unbind("click.content", @clickOnViewerHandler)

        $("html").css cursor: "default"
        $cnt.css cursor: "default"

        @core.registerTaker("dontHandle", true)
        window.location.hash = revertHash

        $cnt.addClass("nodisplay")

        $(window).off("resize", @update)

    closeClickHandler: =>
        @close(@revertHash)

    clickOnViewerHandler: (event) =>
        event.stopPropagation()

class ImageViewer
    constructor: ->
        window.core.exportFunction "ImageViewer.forceClose",
            @close

    open: (conf) =>
        @conf = conf
        image = @conf.image

        # is imageViewer already open?
        if not $(".image-viewer").hasClass("nodisplay")
            # if so, load the new image
            $(".image-viewer img").remove()

        # fade info bar in if it isnt already
        $(".bar").removeClass("fade")

        if @conf.navigation
            @currentEl = @conf.getCurrentElement()
            unless @currentEl - 1 < @minImage
                $(".arrleft").attr "href", @conf.toLeftHash(@currentEl)
            unless @currentEl + 1 > @maxImage
                $(".arrright").attr "href", @conf.toRightHash(@currentEl)
        
        if @conf.arrowKeys and @conf.navigation
            # set up left and right arrow keys
            $(window).on("keydown", @imageViewerKeyPress)

        #lock scrolling
        if @conf.lockScrolling
            @currentScrollPos = $(window).scrollTop()
            $(".scrolled").css overflow:"hidden"

        viewer = $(".image-viewer")

        # the imageViewer might not have been closed properly;
        # remove leftover image if not already
        viewer.children("img").remove()

        $(image).addClass("link-cursor")
        $(image).prependTo($(".image-viewer"))

        if @conf.enableDragging
            #$(".image-viewer img").drags()
            $(image).click =>
                @close()
            console.log "imageViewer.enableDragging: stub"
        else
            $(image).click =>
                @close()

        viewer.removeClass("nodisplay")
        $(".cross").removeClass("nodisplay")
        if $(".image-viewer img").height() > $(window).height() - 300
            @fadeOutInfo()
            $(".image-viewer img").on("mousemove", @fadeOutInfo)

    close: (forceNoHash=false) =>
        #revert Scrolling
        if @conf.lockScrolling
            $(".scrolled").css overflow:"initial"
            $(window).scrollTop(@currentScrollPos)

        #revert hash
        if @conf.revertHash and not forceNoHash
            window.core.registerTaker("dontHandle", true)
            window.location.hash = @conf.revertHash

        if @conf.arrowKeys
            $(window).off("keydown", @imageViewerKeyPress)

        #close viewer
        $(".image-viewer img").off("mousemove", @fadeOutInfo)
        clearTimeout(@timeout)
        $(".bar").removeClass("fade")
        $(".image-viewer").addClass("nodisplay")
        $(".image-viewer").children("img").remove()

    fadeOutInfo: =>
        clearTimeout(@timeout)
        $(".bar").removeClass("fade")
        $("body").css
        @timeout = setTimeout(=>
            $(".bar").addClass("fade")
        , 2000)

    imageViewerKeyPress: (ev) =>
        keyCode = ev.keyCode
        # left arrow press
        if keyCode is 37 and @currentEl > @conf.minImage
            location.hash = @conf.toLeftHash(@currentEl)
        # right arrow press
        if keyCode is 39 and @currentEl < @conf.maxImage
            location.hash = @conf.toRightHash(@currentEl)


# Global Objects, associated to all other
# objects created due to the modular infrastructure
window.core = new Core
window.constants = Constants
new Tile(Constants)

window.core.exportFunction "ContentViewer.requestInstance", ->
    new ContentViewer()

window.core.exportFunction "ImageViewer.requestInstance", ->
    new ImageViewer()

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

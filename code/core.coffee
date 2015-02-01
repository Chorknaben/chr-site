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
    state: 
        scrolledDown : false
        currentURL   : "null"
        currentPage  : "null"

    debug = (msg) -> console.log "Core: " + msg
        
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

        # Calendar is a exception.
        if hash is "#!/kalender"
            @raiseIndexPage()
            @delegateChildPage("", "#!/kalender")
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
                        # When the user clicks on another link on the page before properly
                        # exiting the ContentViewer, we'll have to close it manually.
                        # TODO: test if still required
                        if not $(".content-viewer").hasClass("nodisplay")
                            @requestFunction "ContentViewer.close", (funcPtr) =>
                                funcPtr(-1, true)
                        @requestFunction "Tile.load", (load) =>
                            load route, true, =>
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
        if (window.location.hash is "#!/" and @requestTaker("pageChanged")) or (location.hash is "#!/kalender")
            debug "Back to Index page"

            #@ensureImageViewerClosed()

            $(".tilecontainer").css display: "initial"
            $(".scrolled").css display: "none"
            $(".scrolled").attr("id", "")

            $("#bg").css opacity: 1
            $(".tilecontainer").css opacity: 1

            if window.ie
                $(".tilecontainer").css display: "block"

            @state["childPage"].onUnloadChild()
            @state["childPage"] = new IndexPage()
            @state["currentPage"] = undefined
            @state["currentURL"] = undefined

            window.nav.reset()

            @requestFunction("ImgRotator.pauseImgRotator", (func) -> 
                console.log "imgRotator: resume"
                func(true))
        else
            #TODO check calendar open
            @state["childPage"].closeCalendar()
            $(".tilecontainer").css display:"block"
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

        if window.currentLanguage is "de"
            console.log "Applying language tpl: GERMAN"
            @setLanguage(window.translationObj.de)
        else if window.currentLanguage is "en"
            console.log "Applying language tpl: ENGLISH"
            @setLanguage(window.translationObj.en)

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

        callback = @requestTaker("pendingCallback")
        if callback then callback()

    setLanguage: (translationSubObj) ->
        console.log "fired"
        for translationCandidate in translationSubObj
            do (translationCandidate) ->
                trc = $(translationCandidate.el)
                if trc.length
                    trc.html(translationCandidate.content)

    initializeTranslationEngine: ->
        $.getJSON "/data/json/translation_deploy.json", (data) =>
            window.translationObj = data        
            @attemptAutoSetLanguage()

            $("#de").click => 
                window.currentLanguage = "de"
                @setLanguage(window.translationObj.de)
            $("#en").click => 
                window.currentLanguage = "en"
                @setLanguage(window.translationObj.en)

    attemptAutoSetLanguage: ->
        if navigator.languages
            lang = navigator.languages[0]
        else
            lang = navigator.language || navigator.userLanguage
        if lang.indexOf("de") == -1
            console.log "Stub: Browser does not seem to accept de: Setting en"
            @setLanguage(window.translationObj.en)

    updateTranslations: ->
        if window.currentLanguage == "de"
            @setLanguage(window.translationObj.de)
        else if window.currentLanguage == "en"
            @setLanguage(window.translationObj.en)

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
        @ev = []

        @contentViewer = @c.requestFunction "ContentViewer.requestInstance", 
            (cView) => @contentViewer = cView()

        $.getJSON "/data/json/events.json", (events) =>
            for ev in events.events
                ev.date = moment(ev.date, "DD.MM.YYYY").format("YYYY-MM-DD")
            window.ev = events.events
            if @clndr
                @clndr.setEvents(events.events)

    onInsertion: =>
        @injectBackground()
        @injectTileBackgrounds()

        unless window.mobile
            @preloadImage()
        @footerLeftClick()
        @initNavDropDown()
        @initNewsRotator()
        @imgRotator(10000)

        @initFeedback()

        @c.exportFunction("ImgRotator.pauseImgRotator", @pauseImgRotator)


    injectBackground: ->
        # Determine the resolution of the client and send it to the server.
        # The server will return a matching background image.
        console.log "injectBackground"
        $ "<img>", src: @bgSrc + "bg"
            .load ->
                $(@).appendTo("#bg")
                $("#bg").css
                    opacity: "1"
                    background:"initial"

                if window.mobile
                    $("#bg").css background:"#1a171a"

                if window.ie
                    $("#bg")[0].style.filter = "alpha(opacity=100)"

    preloadImage: ->
        img = new Image()
        w   = $(window).width()
        h   = $(window).height()
        src = "#{w}/#{h}/bg/blurred"
        img.src = src
        @c.state["blurredbg"] = img

    footerLeftClick: ->
        $(".footer-left a").click (event) =>
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
        $.getJSON "/data/json/newsticker.json", (data) =>
            for d in data.news
                if window.ie then @news = data.news
                $("#newsticker").append($("<li>").html(d))

        unless window.ie
            $("#newsticker").newsTicker({
                    row_height:40,
                    max_rows: 1,
                    pauseOnHover: 1,
                    duration:8000;
                    speed:600;
                    prevButton: $(".up")
                    nextButton: $(".down")
                })
        # $.getJSON "newsticker.json", (data) =>
        #     @news = data.news
        #     @newsRotator(7500)

    newsRotator: (waitFor) ->
        if @currentNewsID is 0
            console.log "newsRotator: init"
            $(".right").children("p").html("+++ #{@news[0]} +++")
            $(".right").children("p").css opacity: 1
            if window.ie
                $(".right").children("p")[0].style.filter = "alpha(opacity=100)"
            @currentNewsID++
            @newsRotator(waitFor)
            
        else
            setTimeout(=> 
                $(".right").children("p").css opacity:0
                if window.ie
                    $(".right").children("p")[0].style.filter = "alpha(opacity=0)"
                setTimeout(=>
                    $(".right").children("p").html("+++ #{@news[@currentNewsID]} +++")
                    $(".right").children("p").css opacity: 1
                    if window.ie
                        $(".right").children("p")[0].style.filter = "alpha(opacity=100)"
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
            $("#" + i).css "background-image" : "url(#{@bgSrc + i + "/tile"})"

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

    notifyHashChange: (newHash) =>
        console.log newHash
        if newHash is "#!/kalender"
            pos = $("#6").offset()
            # If the clients screen does not fit the calendar, open it fullscreen
            #minHgt = $(".bigtile-content").height() + 10 + 40 > 420
            minHgt = false

            @template = _.template($("#calendar-template").html())
            @contentViewer.open
                left:   -> 
                    if window.mobile then return 0
                    if minHgt then $(window).width() * 0.06 else 50
                top:    -> 
                    if minHgt then $(".smalltiles").children().first().offset().top else 50 + 25
                right:  -> 
                    if window.mobile then return 0
                    if minHgt then $(window).width() * 0.06 else 50
                height: -> 
                    if window.mobile then return $(window).height() - 75
                    if minHgt then $(".bigtile-content").height() + 10 + 40 else 
                        $(window).height() - 50 - 25 - 50
                chapter: false
                title: "Kalender"
                caption: "Konzerte, Gottesdienste, Grillparties"
                revertHash: "#!/"
                content: "<div id=\"calendar-full\"></div>"
                animate: true
                onClose: =>
                    @contentViewerOpen = false
                startingPos:
                    left: pos.left
                    top: pos.top
                    width: $("#6").width()
                    height: $("#6").height()

            @contentViewerOpen = true
            @clndr = $("#calendar-full").clndr({
                daysOfTheWeek: ['So','Mo','Di',"Mi","Do","Fr","Sa"]
                events: window.ev
                render: (data) =>
                    @template(data)
                doneRendering: ->

                    # Light up the corresponding event when hovering over the event.
                    $(".event").hover ->
                        day = $(this).children(".day-number").html()
                        if (day.length != 2) then day = "0" + day
                        console.log day
                        $(".event-item." + day).css "background-color": "#0D0C0D"
                    , ->
                        day = $(this).children(".day-number").html()
                        if (day.length != 2) then day = "0" + day
                        console.log day
                        $(".event-item." + day).css "background-color": "#1a171a"


            })
            @clndr.setEvents(window.ev)


    closeCalendar: ->
        if @contentViewerOpen
            @contentViewer.close("#!/")

    needBeComplete: (text...) ->
        for i in text
            if i == ""
                $(".submit").css "background-color":"red"
                $(".submit").val("Alle Felder ausfüllen.")
                return false
        return true

    validateEmail: (email) ->
        re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if not re.test email
            $(".submit").css "background-color":"red"
            $(".submit").val("Korrekte E-Mail angeben.")
            return false
        return true


    initFeedback: ->

        $(".submit").click (ev) =>
            ev.stopPropagation()
            ev.preventDefault()

            name = $(".feedbackform .name").val()
            mail = $(".feedbackform .email").val()
            feedbacktype = $('.feedbackform .option').find(":selected").attr("value");
            text = $(".feedbackform textarea").val()

            if not @needBeComplete(name,mail,text)
                return
                
            if not @validateEmail(mail)
                return

            $.post "/feedback", 
                 email: mail
                 name: name
                 feedbacktype: feedbacktype
                 text: text
                 , (data) ->
                    console.log(data)
                    if data.indexOf("OK") == 0
                        $("input").val("")
                        $("textarea").val("")
                        $(".feedbackform .submit").css "background-color":"green"
                        $(".feedbackform .submit").attr("value", "OK. Danke!")


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
            @preState.css "font-weight" : "normal"

    internalToggle: (toggleThis) ->
        console.log @preState
        if @preState isnt undefined
            @preState.css "font-weight" : "normal"
        toggleThis.css    "font-weight" : "bold"
        @preState = toggleThis


class ContentViewer
    constructor: ->
        @core = window.core
        @contentObj = null
        @OPEN = false

        @core.exportFunction "ContentViewer.close", @close

    open: (contentObj) =>
        @ensureNoDuplicates()

        @OPEN = true

        $cnt = $(".content-viewer")
        console.log "contentViewer: open"

        @contentObj = contentObj

        # Reset Style
        $cnt.attr("style", "")


        if not @contentObj.height
            @contentObj.height = -> "initial"

        if @contentObj.scrollTo
            $.scrollTo(@contentObj.scrollTo.offset().top-@contentObj.top(), 500)

        if @contentObj.bgColor
            $cnt.css "background" : @contentObj.bgColor

        $cnt.removeClass("nodisplay")
        if @contentObj.animate
            pos = @contentObj.startingPos

            # Spawn the Content-Viewer at the desired location
            $cnt.css 
                left: pos.left
                top: pos.top
                width: pos.width 
                height: pos.height
                "z-index" : 6

            $cnt.css
                opacity: 1
                width: 
                    if not @contentObj.width
                        $(window).width() - @contentObj.right() - @contentObj.left()
                    else @contentObj.width()
                left: @contentObj.left()
                height: @contentObj.height()
                top: @contentObj.top()

            $(".content-viewer-padding").css
                opacity: 1
            @continue($cnt)
        else
            $(".content-viewer-padding").css
                opacity: 1
            $cnt.css
                opacity: 1
            @continue($cnt)


    continue: ($cnt) ->
        $("html").css cursor:"pointer"
        $("html .content-viewer").css cursor:"initial"
        @update()
        $content = $cnt.children("div")

        # Only needed for Contentviewers without translation
        if @contentObj.title or @contentObj.caption or @contentObj.content
            $content.children("h1").html(@contentObj.title)
            $content.children("h2").html(@contentObj.caption)
            $content.children("#ccnt").html(@contentObj.content)

        window.core.updateTranslations()

        $("#content-viewer-exit-button").removeClass("nodisplay")
        $("#content-viewer-exit-button").on "click", => @close(@contentObj.revertHash)

        $(document).bind("click.content", @closeClickHandler)
        $(".content-viewer").bind("click.content", @clickOnViewerHandler)

        $(window).on("resize", @update)


    update: =>
        $(".content-viewer").css
            left: @contentObj.left()
            top: @contentObj.top()
            width:
                if not @contentObj.width
                    $(window).width() - @contentObj.right() - @contentObj.left()
                else @contentObj.width()
            height: @contentObj.height()
            

    close: (revertHash, noAnimationOverride=false) =>
        $cnt = $(".content-viewer")
        console.log "contentViewer: close"

        $("#content-viewer-exit-button").addClass("nodisplay")

        # Note: Removing all click events here.... Possible Bug source
        $(document).unbind("click")
        $(".content-viewer").unbind("click")
        $("#content-viewer-exit-button").off "click"

        $("html").css cursor: "default"
        $cnt.css cursor: "default"

        unless revertHash is -1
            @core.registerTaker("dontHandle", true)
            window.location.hash = revertHash

        if @contentObj.animate and not noAnimationOverride
            # revert contentViewer to original position
            $cnt.css
                left: @contentObj.startingPos.left
                width: @contentObj.startingPos.width
                top: @contentObj.startingPos.top
                height: @contentObj.startingPos.height

            # now turn off timing transition because we want this
            # opacity to be transitioned immediately.
            $cnt.children("div").addClass("nodisplay")
            setTimeout( =>
                $cnt.css
                    opacity: 0
                setTimeout( =>
                    $cnt.addClass("nodisplay")
                    $cnt.children("div").removeClass("nodisplay")
                    $(".content-viewer-padding").css opacity:0
                    window.location.hash = revertHash
                    @reset()
                    @OPEN = false
                , 400)
            , 600)
                
        else
            $cnt.addClass("nodisplay")

        $(window).off("resize", @update)
        @clear()

        if @contentObj.onClose
            @contentObj.onClose()

    clear: ->
        $(".content-viewer-padding h1").empty()
        $(".content-viewer-padding h2").empty()
        $("#ccnt").empty()

    reset: ->
        @clear()
        $(".content-viewer").attr("style", "")

    ensureNoDuplicates: ->
        # Is another Contentviewer open?
        # If so, we must take several precautions and reset the Contentviewers DOM
        if not $(".content-viewer").hasClass("nodisplay") or @OPEN
            console.log "Contentviewer: Duplicate Instance detected. Closing."
            @contentObj.animate = false
            @close(-1)

    closeClickHandler: =>
        @close(@contentObj.revertHash)

    clickOnViewerHandler: (event) =>
        event.stopPropagation()

class ImageViewer
    CLOSED: 0x00
    OPEN:   0x01
    constructor: ->
        @state = @CLOSED
        window.core.exportFunction "ContentViewer.forceClose",
            @close

    open: (conf) =>
        @conf = conf

        @resetViewer()


        if @conf.navigation
            @currentEl = @conf.getCurrentElement()
            unless (@currentEl) == @conf.minImage
                $(".arrleft").attr "href", @conf.toLeftHash(@currentEl)
                if @conf.nextChapterScreen
                    if @conf.positionInChapter == "1" 
                        $(".arrleft").attr "href", "#!/bilder/kategorie/#{@conf.chapterID}"
            else
                # Stay at 0 if clicking left at 0
                # An Indicator that there arent any more Pics available can be added HERE!!!
                $(".arrleft").attr "href", @conf.toLeftHash(@currentEl+1)

            unless (@currentEl) == @conf.maxImage
                $(".arrright").attr "href", @conf.toRightHash(@currentEl)
                if @conf.nextChapterScreen
                    if @conf.positionInChapter == @conf.chapterTotalLength
                        $(".arrright").attr "href", "#!/bilder/kategorie/#{@conf.chapterID+1}"
            else
                # Stay at maxImage if clicking right at 0
                # An Indicator that there arent any more Pics available can be added HERE!!!
                $(".arrright").attr "href", @conf.toRightHash(@currentEl-1)
        
        #lock scrolling
        if @conf.lockScrolling
            @currentScrollPos = $(window).scrollTop()
            $(".scrolled").css overflow:"hidden"

        viewer = $(".image-viewer")

        if @conf.title
            $("#image-title").html(@conf.title)

        # (x of y - Anzeige)
        if @conf.positionInChapter and @conf.chapterTotalLength
            $("#chapter-progress").html("(Bild #{@conf.positionInChapter} von #{@conf.chapterTotalLength})")

        if @conf.chapterName
            $("#chapter-name-main").html(@conf.chapterName[0]) 
            $("#chapter-name-caption").html(@conf.chapterName[1])

        if @conf.descriptionSetting
            switch @conf.descriptionSetting
                # disable bottom bar
                when 1 
                    $(".bar").addClass "nodisplay"


        # the imageViewer might not have been closed properly;
        if @conf.handleImageLoading
            img = new Image()
            $(img).prependTo($(".image-viewer"))
            viewer.children("img").addClass("link-cursor")
            img.src = @conf.imagesource
        else
            image = @conf.image
            $(image).addClass("link-cursor")
            $(image).prependTo($(".image-viewer"))

        if @conf.enableDragging
            #$(".image-viewer img").drags()
            console.log "imageViewer.enableDragging: stub"

        # Click on Image -> Close    
        $(".image-viewer img").first().click =>
            @close()

        # Enable Exit button
        $("#image-viewer-exit-button").removeClass("nodisplay")
        $("#image-viewer-exit-button").on "click", => @close()

        viewer.removeClass("nodisplay")
        $(".cross").removeClass("nodisplay")
        if $(".image-viewer img").first().height() > $(window).height() - 300
            @fadeOutInfo()
            $(".image-viewer img").first().on("mousemove", @fadeOutInfo)

        @state = @OPEN

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
        $(".image-viewer img").first().off("mousemove", @fadeOutInfo)
        clearTimeout(@timeout)
        $(".bar").removeClass("fade")
        $(".image-viewer").addClass("nodisplay")
        $("#image-viewer-exit-button").addClass("nodisplay")
        $(".image-viewer img").first().remove()

        @state = @CLOSED

    resetViewer: ->
        # Prepare ImageViewer for next usage
        # Is imageViewer already open?
        if not $(".image-viewer").hasClass("nodisplay")
            # if so, load the new image
            $(".image-viewer img").first().remove()

        # Remove leftovers from inline chapter
        $(".image-viewer .chapter-info-inline").remove()

        # fade info bar in if it isnt already
        $(".bar").removeClass("fade")

        # enable bar if it isnt already
        $(".bar").removeClass("nodisplay")

        # remove leftover image if not already
        $('.image-viewer img').first().remove()

    getState: ->
        return @state

    fadeOutInfo: =>
        clearTimeout(@timeout)
        $(".bar").removeClass("fade")
        $("body").css
        @timeout = setTimeout(=>
            $(".bar").addClass("fade")
        , 3500)


class Tile
    constructor: (@const) ->
        @core = window.core
        @interval = null
        @scaleCount = 0
        @headerImg = $("#header-img")

        @core.exportFunction("Tile.finalizeLoading", @finalizeLoading)
        @core.exportFunction("Tile.load", @load)
        #@core.exportFunction("Tile.navDown", @navigationDown)

    load: (urlWhat, animate=false, callback, originalSite=undefined, urlOverride=undefined, bare=false) =>
        # Animations happening on Click
        # --------
        unless bare
                window.nav.by(@const.METHODS.NAME_USER, urlWhat)

        # Load content
        # --------
        @core.state["globalHashResponseDisabled"] = true
        $("#result").load "content/#{ urlWhat }.html", =>
            if animate
                @setLoadingScreen(true)

            # Insert background Image
            unless window.mobile
                $(@core.state["blurredbg"]).appendTo("#blurbg")

            if not originalSite
                $(".scrolled").attr("id", urlWhat)
            else
                $(".scrolled").attr("id", originalSite)

            #@core.state["currentPage"] = prettyWhat
            if not urlOverride
                @core.state["currentURL" ] = urlWhat
            else
                @core.state["currentURL"] = urlOverride
            @core.state["tileid"] = @tileid
            @core.registerTaker("pageChanged", true)

            $.when(
                $.getScript "content/#{ urlWhat }.js",
                $.Deferred (deferred) ->
                    $(deferred.resolve)
            ).done =>
                # Execute onLoad of inserted Child Page
                @core.state["childPage"].onLoad()
                if @core.state["childPage"].acquireLoadingLock()
                    console.log "here"
                    console.log @core.state["childPage"]
                    # Continue showing loading screen until Child Page
                    # releases the lock
                    @core.registerTaker("pendingCallback", callback)
                    return
                @finalizeLoading(callback, animate)

    finalizeLoading: (callback=undefined, animate=true) =>
        moreHash = @core.requestTaker("backupHash")
        if typeof moreHash isnt "undefined"
            #maybe re-get-the-loading-lock!
            window.location.hash = moreHash
        if animate
            @setLoadingScreen(false)
        else
            $(".tilecontainer").css display: "none"
            @core.state["childPage"].onDOMVisible()

        $("#result").css display: "block"
        @core.state["globalHashResponseDisabled"] = false

        if callback then callback()

    setLoadingScreen: (toggle) ->
        if toggle
            #$("#loading-screen").css 
            #    opacity:0.5
            #    display:"block"
            $("#bg").css
                opacity:0
            $(".tilecontainer").css
                display:"none"
            setTimeout(=>
                @animationEnded = true
            , 400)
        else
            if not @animationEnded
                setTimeout(=> 
                    @setLoadingScreen(false)
                , 50)
                return
            $(".rootnode").css opacity: 1
            $("#loading-screen").css opacity:0
            @core.state["childPage"].onDOMVisible()
            setTimeout(-> $("#loading-screen").css display:"none", 200)

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
    moment.lang("de")

    unless window.ie
        isMobile = window.matchMedia("only screen and (max-width: 1000px)")
        if isMobile.matches then window.mobile = true

    if window.ie
        svgs = document.getElementsByTagName("img")
        for svg in svgs
            attr= svg.getAttribute("src");
            if attr.indexOf(".svg", attr.length - 4) != -1
                svg.setAttribute("src",attr+".png");

    audiojs.events.ready ->
        audiojs.createAll()

    # Important initialization code
    c = window.core
    #
    # Initial Page is the Index Page
    c.initializeHashNavigation()
    c.insertChildPage(new IndexPage())

    c.initializeTranslationEngine()

    c.handleHash()


    window.onhashchange = c.handleHash

class Tile
    constructor: (@const) ->
        @core = window.core
        @interval = null
        @scaleCount = 0
        @headerImg = $("#header-img")

        @core.exportFunction("Tile.finalizeLoading", @finalizeLoading)
        @core.exportFunction("Tile.load", @load)
        #@core.exportFunction("Tile.navDown", @navigationDown)

    load: (urlWhat, callback, originalSite=undefined, urlOverride=undefined, bare=false) =>
        # Animations happening on Click
        # --------
        unless bare
                window.nav.by(@const.METHODS.NAME_USER, urlWhat)

        # Load content
        # --------
        @core.state["globalHashResponseDisabled"] = true
        $("#result").load "content/#{ urlWhat }.html", =>
            @setLoadingScreen(true)

            # Insert background Image
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
                @finalizeLoading(callback)

    finalizeLoading: (callback=undefined) =>
        moreHash = @core.requestTaker("backupHash")
        if typeof moreHash isnt "undefined"
            #maybe re-get-the-loading-lock!
            window.location.hash = moreHash
        @setLoadingScreen(false)
        $("#result").css display: "initial"
        $(".tilecontainer").css display: "none"

        @core.state["globalHashResponseDisabled"] = false

        @core.state["childPage"].onDOMVisible()
        if callback then callback()
        #callback() here



    setLoadingScreen: (toggle) ->
        if toggle
            $("#loading-screen").css display: "block"
        else
            $("#loading-screen").css display: "none"

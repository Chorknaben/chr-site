class Tile
    constructor: (@tileid, @const=Constants) ->
        @core = window.core
        @interval = null
        @scaleCount = 0
        @headerImg = $("#header-img")

        @core.exportFunction("Tile.finalizeLoading", @finalizeLoading)
        @core.exportFunction("Tile.load", @load)
        #@core.exportFunction("Tile.navDown", @navigationDown)

    onClick: =>
        console.log "Tile Click: id=#{@tileid}"
        if @tileid > 7 then @tileid -= 7
        console.log @const.tileResolver
        @load(
           @const.tileResolver[@tileid-1][0],
           @const.tileResolver[@tileid-1][1]
        )

    load: (prettyWhat, urlWhat, bare=false) ->
        # Animations happening on Click
        # --------
        console.log urlWhat
        unless bare then window.nav.by(@const.METHODS.NAME, urlWhat)

        # Load content
        # --------
        $("#result").load "content/#{ urlWhat }.html", =>
            # Set new Hash
            window.location.hash = "!/" + urlWhat

            @setLoadingScreen(true)

            # Insert background Image
            $(@core.state["blurredbg"]).appendTo("#blurbg")

            $(".scrolled").attr("id", urlWhat)
            @core.state["currentPage"] = prettyWhat
            @core.state["currentURL" ] = urlWhat
            @core.state["tileid"] = @tileid
            @core.registerTaker("pageChanged", true)

            $.getScript "content/#{ urlWhat }.js"
                .done =>
                    # Execute onLoad of inserted Child Page
                    @core.state["childPage"].onLoad()
                    if @core.state["childPage"].acquireLoadingLock()
                        # Continue showing loading screen until Child Page
                        # releases the lock
                        return
                    @finalizeLoading()

    finalizeLoading: =>
        moreHash = @core.requestTaker("backupHash")
        if typeof moreHash isnt "undefined"
            #maybe re-get-the-loading-lock!
            window.location.hash = moreHash
        @setLoadingScreen(false)
        $("#result").css display: "initial"
        $(".tilecontainer").css display: "none"
        @core.state["childPage"].onDOMVisible()


    setLoadingScreen: (toggle) ->
        if toggle
            $("#loading-screen").css display: "block"
        else
            $("#loading-screen").css display: "none"

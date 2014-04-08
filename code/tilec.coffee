class Tile
    constructor: (@tileid, @const=Constants) ->
        @core = window.core
        @interval = null
        @scaleCount = 0
        @headerImg = $("#header-img")

        #@core.exportFunction("Tile.navDown", @navigationDown)

    onClick: =>
        console.log "Tile Click: id=#{@tileid}"
        if @tileid > 7 then @tileid -= 7
        console.log @const.tileResolver
        @load(
           @const.tileResolver[@tileid-1][0],
           @const.tileResolver[@tileid-1][1]
        )

    load: (prettyWhat, urlWhat) ->
        # Animations happening on Click
        # --------
        console.log urlWhat
        window.nav.by(@const.METHODS.NAME, urlWhat)

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
                    @core.state["childPage"].onGenerateMarkup()
                    # Execute onLoad of inserted Child Page
                    @core.state["childPage"].onLoad()
                    @setLoadingScreen(false)
                    $("#result").css display: "initial"
                    $(".tilecontainer").css display: "none"
                    #$.scrollTo ".scrolled", 800, onAfter: =>
                    #    # Execute onScrolledDown of inserted Child Page
                    #    @core.state["childPage"].onScrollFinished()
                    #    @core.state["scrolloff"  ] = $(window).scrollTop()

                    #    # Change Title and fade in
                    #    #$(".ctitle").html("Chorknaben")
                    #    #$(".ctitle").fadeTo(200, 1)

                    #    # Revert state that animations modified
                    #    $("#loading-img").css visibility:"hidden"
                    #    @scaleCount = 0
        #$(".ctitle").fadeTo(200, 0)

    setLoadingScreen: (toggle) ->
        if toggle
            $("#loading-screen").css display: "block"
        else

            $("#loading-screen").css display: "none"

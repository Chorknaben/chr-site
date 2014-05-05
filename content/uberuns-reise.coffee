class UberunsReise extends ChildPage
    constructor: ->
        @core = window.core
        @showMap = false

    onLoad: ->
        $.when(
            $.getScript("/code/jquery.vmap.europe.js"),
            $.getScript("/code/jquery.vmap.min.js"),
            $.Deferred (deferred) ->
                $(deferred.resolve)
        ).then( ->
            console.log "sucess"
            @showMap = true
            window.core.release()
        , ->
            console.log "fail"
            window.core.release()
        )
            

    onDOMVisible: ->
        console.log "in onASDvisible"
        @reisehack()
        $(window).on("resize", @reisehack)
        if @showMap
            @setupMap()
            $(window).on("resize", @setupMap)

    onUnloadChild: ->
        $(window).off("resize", @reisehack)
        $(window).off("resize", @setupMap)

    notifyHashChange: (newHash) ->
        #console.log "getting hash: #{newHash}"
        #@core.requestFunction("Tile.load", (load) ->
        #    newHash = newHash.substr(1,newHash.length)
        #    @core.registerTaker("dontHandle", true)
        #    load("Über uns", "uberuns-#{newHash}", "uberuns" ,"uberuns/#{newHash}", true)
        #    @core.requestTaker("dontHandle")
        #, $.noop)

    acquireLoadingLock: ->
        return true

    setupMap: ->
        wReiseTile = $(".reise-tile").eq(0).width()
        hReiseTile = $(".reise-tile").eq(0).height()
        $("#map").css height: hReiseTile, width:wReiseTile
        console.log hReiseTile
        console.log $("#map").css("height")
        $('#map').vectorMap
            map: 'europe_en',
            backgroundColor: null,
            color: '#ffffff',
            hoverColor: '#999999',
            enableZoom: false,
            showTooltip: false

    reisehack: =>
        # TODO minor hack, solve using css
        wReiseTile = $(".reise-tile").eq(0).height()
        $("#reise-onleft").css height: 2 * wReiseTile + 10


window.core.insertChildPage(new UberunsReise())

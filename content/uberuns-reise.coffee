class UberunsReise extends ChildPage
    constructor: ->
        @core = window.core
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()
            # TODO do something awesome with this!

    onLoad: ->
        $.when(
            $.getScript("/code/jquery.vmap.js"),
            $.getScript("/code/jquery.vmap.europe.js"),
            $.Deferred (deferred) ->
                $(deferred.resolve)
        ).then( ->
            console.log "sucess"
            window.core.release()
        , ->
            console.log "fail"
            window.core.release()
        )
            

    onDOMVisible: =>
        console.log "in onASDvisible"
        @reisehack()
        $(window).on("resize", @reisehack)
        @setupMap()
        $(window).on("resize", @resizeMap)

    onUnloadChild: ->
        $(window).off("resize", @reisehack)
        $(window).off("resize", @resizeMap)

    notifyHashChange: (newHash) ->
        console.log newHash
        if newHash.lastIndexOf("/info/", 0) is 0
            # Load Info Block
            number = parseInt(newHash.substr(6, newHash.length))


    acquireLoadingLock: ->
        return true

    resizeMap: =>
        $("#map").children().remove()
        $(".jqvmap-label").remove()
        @setupMap()


    setupMap: =>
        wReiseTile = $(".reise-tile").eq(0).width()
        hReiseTile = $(".reise-tile").eq(0).height()
        $("#map").css height: hReiseTile, width:wReiseTile
        console.log $("#map").width()
        $('#map').vectorMap
            map: 'europe_en',
            backgroundColor: "#1a171a",
            color: '#ffffff',
            hoverColor: '#999999',
            enableZoom: false,
            showTooltip: false

    reisehack: =>
        # TODO minor hack, solve using css
        wReiseTile = $(".reise-tile").eq(0).height()
        $("#reise-onleft").css height: 2 * wReiseTile + 10


window.core.insertChildPage(new UberunsReise())

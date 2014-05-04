class UberunsReise extends ChildPage
    constructor: ->
        @core = window.core

    onLoad: ->

    onDOMVisible: ->
        @reisehack()
        $(window).on("resize", @reisehack)

    onUnloadChild: ->
        $(window).off("resize", @reisehack)

    notifyHashChange: (newHash) ->
        console.log "getting hash: #{newHash}"
        @core.requestFunction("Tile.load", (load) ->
            newHash = newHash.substr(1,newHash.length)
            @core.registerTaker("dontHandle", true)
            load("Über uns", "uberuns-#{newHash}", "uberuns" ,"uberuns/#{newHash}", true)
            @core.requestTaker("dontHandle")
        , $.noop)

    reisehack: =>
        # TODO minor hack, solve using css
        wReiseTile = $(".reise-tile").eq(0).height()
        $("#reise-onleft").css height: 2 * wReiseTile + 10


window.core.insertChildPage(new UberunsReise())

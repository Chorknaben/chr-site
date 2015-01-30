class UberunsReise extends ChildPage
    constructor: ->
        @core = window.core
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

        @metadata = {
            r1: {
                    title: "&Ouml;sterreich &amp; Ungarn"
                    caption: "Konzertreise 2012"
                    textID: "#osterreich"
                    linkBilder: "#!/bilder/kategorie/by-title/konzertreise-2012"
                    thumbnail: "/img/ungarn.jpg"
                },
            r2: {
                    title: "Deutschland &amp; Holland"
                    caption: "Konzertreise 2013"
                    textID: "#deutschland"
                    thumbnail: "/img/deutschland.jpg"
                    linkBilder: "#!/bilder/kategorie/by-title/konzertreise-2013"
                },
            r3: {
                    title: "Spanien"
                    caption: "Konzertreise 2014"
                    textID: "#spanien"
                    thumbnail: "/img/spanien.jpg"
                    linkBilder: "#!/bilder/kategorie/by-title/konzertreise-2014" 
            }
        }

    onLoad: ->
        $.when(
            $.getScript("/code/jquery.vmap.js"),
            $.getScript("/code/jquery.vmap.europe.js"),
            $.getScript("/code/jquery.vmap.world.js"),
            $.Deferred (deferred) ->
                $(deferred.resolve)
        ).done( ->
            window.core.release()
        ) 

        # First 3 Tiles get a slick mouseover effect
        for i in [0..2]
            $(".reise-tile").eq(i).hover(->
                $(this).find("h1").addClass("fade")
            ,-> $(this).find("h1").removeClass("fade"))

    onDOMVisible: =>
        unless window.ie
            @reisehack()
            $(window).on("resize", @reisehack)
        @setupMap()


    onUnloadChild: ->
        $(window).off("resize", @reisehack)

    notifyHashChange: (newHash) ->
        if newHash.lastIndexOf("/info/", 0) is 0
            # Load Info Block
            number = parseInt(newHash.substr(6, newHash.length))
            metaobj = undefined
            switch number
                when 1 then metaobj = @metadata.r1
                when 2 then metaobj = @metadata.r2
                when 3 then metaobj = @metadata.r3

            w = $(window).width()
            h = $(window).height()

            elem = $("#rt#{number}")
            offs = elem.offset()

            @contentViewer.open
                left:   -> (w/2) - (1000/2)
                top:    -> (h/2) - (600/2)
                right:  -> (w/2) - (1000/2)
                height: -> 600
                chapter: false
                title: metaobj.title
                caption: metaobj.caption
                revertHash: "#!/uberuns/reise"
                content: $("#content-reise").html()
                animate:true
                startingPos:
                    left: offs.left
                    top: offs.top
                    width:elem.width()
                    height:elem.height()

            @populate(metaobj.textID, metaobj.linkBilder, metaobj.thumbnail)


    populate: (textPtr, bilderLink, thumbnail) ->
        # Den Contentviewer mit Daten anreichern. 
        # Diese sind bis jetzt provisorisch im Metaobj, später im JSON oder MySQL Abteil

        # Linker Abteil
        $(".reise-left-tile").removeClass("reise-left-tile-inactive")
        if bilderLink is -1
            $(".reise-left-tile").addClass("reise-left-tile-inactive")
        else    
            $(".reise-left-tile").attr("href", bilderLink)
        $(".reise-left-tile img").attr("src", thumbnail)

        # Rechter Abteil
        $(".reise-right-titel").html($(textPtr).children("h1").html())
        $(".reise-right-content").html($(textPtr).children("p").html())


    acquireLoadingLock: ->
        return true

    setupMap: =>
        wReiseTile = $(".reise-tile").eq(0).width()
        hReiseTile = $(".reise-tile").eq(0).height()
        $("#map").css height: hReiseTile, width:wReiseTile
        console.log $("#map").width()
        $('#map').vectorMap
            map: 'europe_en',
            backgroundColor: "#1a171a",
            borderColor: '#1a171a',
            borderWidth: 0,
            color: '#ffffff',
            hoverColor: '#999999',
            enableZoom: false,
            showTooltip: true,
            colors:
                de: "#199250"
                es: "#305596"
                gb: "#199250"
                at: "#199250"
                dk: "#199250"
                cz: "#199250"
                fr: "#199250"
                it: "#199250"
                se: "#199250"
                no: "#199250"
                nl: "#199250"
                ch: "#199250"
                hu: "#199250"
                si: "#199250"
                hr: "#199250"
                ro: "#199250"
                sl: "#199250"

        $("#map-world").vectorMap
            map: 'world_en',
            backgroundColor: "#1a171a",
            borderColor: '#1a171a',
            color: '#ffffff',
            hoverColor: '#999999',
            enableZoom: false,
            showTooltip: true,
            colors:
                de: "#199250"
                es: "#305596"
                gb: "#199250"
                at: "#199250"
                dk: "#199250"
                cz: "#199250"
                fr: "#199250"
                it: "#199250"
                se: "#199250"
                no: "#199250"
                nl: "#199250"
                ch: "#199250"
                hu: "#199250"
                si: "#199250"
                hr: "#199250"
                ro: "#199250"
                us: "#199250"
                sl: "#199250"

    reisehack: =>
        # TODO minor hack, solve using css
        wReiseTile = $(".reise-tile").eq(0).height()
        $("#reise-onleft").css height: 2 * wReiseTile + 10


window.core.insertChildPage(new UberunsReise())

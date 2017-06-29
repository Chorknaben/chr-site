class UberunsReise extends ChildPage
    constructor: ->
        @core = window.core
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

        @metadata = {
            r1: {
                    title: "Spanien"
                    caption: "Konzertreise 2014"
                    textID: "#spanien"
                    thumbnail: "/img/spanien.jpg"
                    linkBilder: "#!/bilder/kategorie/by-title/konzertreise-2014" 
            }
            r2: {
                    title: "Tschechien und Polen"
                    caption: "Konzertreise 2015"
                    textID: "#tschechien-polen"
                    linkBilder: "#!/bilder/kategorie/by-title/konzertreise-2015"
                    thumbnail: "/img/tschechien-polen.jpg"
                },
            r3: {
                    title: "Frankreich, England, Guernsey"
                    caption: "Konzertreise 2016"
                    textID: "#frankreich-england"
                    thumbnail: "/img/england-guernsey.jpg"
                    linkBilder: "#!/bilder/kategorie/by-title/konzertreise-2016"
            }
        }

    onLoad: ->
        window.core.setMetaDesc("Konzertreise", "Konzertreise")
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
        unless window.ie or window.mobile()
            @reisehack()
            $(window).on("resize", @reisehack)
        @setupMap()


    onUnloadChild: ->
        window.core.revMetaDesc()
        unless window.ie or window.mobile
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
                height: -> 600+"px"
                chapter: false
                title: metaobj.title
                caption: metaobj.caption
                revertHash: "#!/uberuns/reise"
                content: $("#content-reise").html()
                animate:false

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
                lu: "#199250"
                be: "#199250"
                pl: "#199250"

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
                us: "#199250"
                lu: "#199250"
                be: "#199250"
                pl: "#199250"

    reisehack: =>
        # TODO minor hack, solve using css
        wReiseTile = $(".reise-tile").eq(0).height()
        $("#reise-onleft").css height: 2 * wReiseTile + 10


window.core.insertChildPage(new UberunsReise())

class UberunsReise extends ChildPage
    constructor: ->
        @core = window.core
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

    onLoad: ->
        $.when(
            $.getScript("/code/jquery.vmap.js"),
            $.getScript("/code/jquery.vmap.europe.js"),
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
        @reisehack()
        $(window).on("resize", @reisehack)
        @setupMap()
        $(window).on("resize", @resizeMap)

    onUnloadChild: ->
        $(window).off("resize", @reisehack)
        $(window).off("resize", @resizeMap)

    notifyHashChange: (newHash) ->
        if newHash.lastIndexOf("/info/", 0) is 0
            # Load Info Block
            number = parseInt(newHash.substr(6, newHash.length))
            w = $(window).width()
            h = $(window).height()

            elem = $("#rt#{number}")
            offs = elem.offset()
            @contentViewer.open
                left:   -> $("#uberuns-cnt").offset().left + 10
                top:    -> $(".reise-tile").offset().top 
                right:  -> w - $("#uberuns-cnt").width() - (w * 0.04) - 2
                height: ->  $("#uberuns-cnt").height() + 10
                chapter: false
                title: "MOSKAU &amp; STALINGRAD"
                caption: "1945"
                revertHash: "#!/uberuns/reise"
                content: "<p>Prosciutto sirloin filet mignon pancetta. Rump frankfurter tail, fatback cow tenderloin ham hock. Strip steak meatball beef shank doner jowl turducken bacon t-bone biltong salami. Prosciutto meatball pancetta filet mignon brisket ham jowl sirloin. Biltong ground round brisket, sirloin tail corned beef pig pork chop ball tip shoulder beef ribs frankfurter beef pork salami.</p>"
                animate:true
                startingPos:
                    left: offs.left
                    top: offs.top
                    width:elem.width()
                    height:elem.height()




    acquireLoadingLock: ->
        return true

    resizeMap: =>
        $("#map").remove()
        $(".jqvmap-label").remove()
        $(".reise-tile").eq(3).append(
            $("<div>").attr("id", "map")
        )
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
            showTooltip: true,
            colors:
                de: "#34ef34"
                es: "#9b4f37"
                gb: "#34ef34"
                at: "#34ef34"
                dk: "#34ef34"
                cz: "#34ef34"
                fr: "#34ef34"
                it: "#34ef34"
                se: "#34ef34"
                no: "#34ef34"

    reisehack: =>
        # TODO minor hack, solve using css
        wReiseTile = $(".reise-tile").eq(0).height()
        $("#reise-onleft").css height: 2 * wReiseTile + 10


window.core.insertChildPage(new UberunsReise())

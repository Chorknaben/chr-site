class Uberuns extends ChildPage
    constructor: ->
        @core = window.core
        window.core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

    onDOMVisible: ->
        #if window.ie
            $(".reise-imgcontainer").css display:"none"
            $(".reise-sidebarcontainer").css display:"none"
            $(".ie8-fallback-tile").css display:"initial"

    notifyHashChange: (newHash) ->
        h = $(".hiddentext")
        if newHash == "/chorknabe-werden"
            @contentViewer.open
                left:   -> h.offset().left
                top:    -> h.offset().top
                width:  -> h.width()
                height: -> h.height()
                minWidth: -> "500px"
                chapter: false
                bgColor: "#4b77be"
                title: "Chorknabe werden."
                caption: ""
                revertHash: "#!/uberuns/"
                content: $("#chorknabe-werden").html()

    getDimText: ->
        h = $(".hiddentext")
        return [h.height(), h.width(), h.offset()]

    onLoad: ->
        # User accesses information text mainly by hovering over the image
        $(".hiddentext").addClass("visible")

        # We're going to to a little animation with these buttons,
        # so attach onclick events to them
        $(".icon-container").click (event) ->
            if not $(".content-viewer").hasClass("nodisplay")
                # ContentViewer still open
                @contentViewer.close(-1, true)

            $("#uberuns").css {"margin-left" : - ( $(window).width() * 0.06 + $(".deadcenter").width() - 50 )}
            setTimeout( =>
                location.hash = $(this).attr("href")
            , 1000)

            event.stopPropagation()
            event.preventDefault()
        

        window.core.release()

    mouseEnter: ->


window.core.insertChildPage(new Uberuns())

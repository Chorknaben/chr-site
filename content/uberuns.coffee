class Uberuns extends ChildPage
    constructor: ->
        @core = window.core
        @core.state["uberuns-doesnothing"] = true

    onDOMVisible: ->

    notifyHashChange: (newHash) ->

    onLoad: ->
        # User accesses information text mainly by hovering over the image
        $(".testblock").hover(->
            setTimeout( ->
                @core.state["uberuns-doesnothing"] = false
                if $(".testblock:hover").length > 0
                    $(".testblock").addClass("text")
            , 700)
        ,->
            $(this).removeClass("text")
        )

        # User can also click on the image to achieve the same
        # effect
        $(".testblock").click ->
            @core.state["uberuns-doesnothing"] = false
            $(".testblock").addClass("text")

        # If the user does nothing for 3 secs, hint him that
        # he could hover over that huge image right there
        setTimeout( =>
            if @core.state["uberuns-doesnothing"]
                $(".testblock").addClass("hint")
        , 3000)

        # We're going to to a little animation with these buttons,
        # so attach onclick events to them
        $(".icon-container").click (event) ->
            console.log "asdasd"
            $("#uberuns").css {"margin-left" : - ( $(window).width() * 0.06 + $(".deadcenter").width() - 50 )}
            setTimeout( =>
                location.hash = $(this).attr("href")
            , 1000)

            event.stopPropagation()
            event.preventDefault()
        

        window.core.release()

    mouseEnter: ->


window.core.insertChildPage(new Uberuns())

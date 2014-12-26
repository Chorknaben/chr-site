class Uberuns extends ChildPage
    constructor: ->
        @core = window.core
        @core.state["uberuns-doesnothing"] = true

    onDOMVisible: ->
        #if window.ie
            $(".reise-imgcontainer").css display:"none"
            $(".reise-sidebarcontainer").css display:"none"
            $(".ie8-fallback-tile").css display:"initial"

    notifyHashChange: (newHash) ->

    onLoad: ->
        # User accesses information text mainly by hovering over the image
        $(".hiddentext").addClass("visible")

        # We're going to to a little animation with these buttons,
        # so attach onclick events to them
        $(".icon-container").click (event) ->
            $("#uberuns").css {"margin-left" : - ( $(window).width() * 0.06 + $(".deadcenter").width() - 50 )}
            setTimeout( =>
                location.hash = $(this).attr("href")
            , 1000)

            event.stopPropagation()
            event.preventDefault()
        

        window.core.release()

    mouseEnter: ->


window.core.insertChildPage(new Uberuns())

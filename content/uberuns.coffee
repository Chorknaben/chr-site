class ImageCarusel
    contructor: (@imagediv) ->
        @left = $(@imagediv).find(".left")
        @main = $(@imagediv).find(".main")
        @right = $(@imagediv).find(".right")

    load: ->
        for i in [@left, @main, @right]
            $(i).bind "load", ->
                @.fadeIn()
    click_left: (event) ->
    click_middle: (event) ->
    click_right: (event) ->

class ExperienceHandler
    constructor: ->
        # All waypoints in uberuns.html
        @waypoints = $( ".waypoint" )
        @c         = window.core
        @w         = $( window )
        @c.state["eingerastet"] = false
        @topOnRast = -1

    scroll: ->
        stackFst  = $ @waypoints[0]
        stackFstB = stackFst.children('.wbody')
        stackFstC = stackFst.children('.connector')
        fstEdge   = stackFstB.offset().top + stackFstB.height()
        stackHgt  = 279 + stackFstB.height()

        stackSnd  = $ @waypoints[1]
        stackSndI = stackSnd.children('img')

        fstDelta  = stackSndI.offset().top - fstEdge

        if @w.scrollTop() > @w.height()
            stackFst.css position: "fixed"

        stackFstC.css
            height: stackSndI.offset().top - stackFstC.offset().top + 8

        if fstDelta <= 0
            stackFst.css opacity: 1 - Math.abs(fstDelta) * (1 / stackHgt)

        if stackFstC.height() is 0 and not @c.state["eingerastet"]
            @c.state["eingerastet"] = true
            stackSnd.css position:'fixed', top:'150px'
            @topOnRast = $(window).scrollTop()

        if $(window).scrollTop() < @topOnRast and @c.state["eingerastet"]
            @c.state["eingerastet"] = false
            stackSnd.css position:'absolute', top:'714px'


$( "body" ).on
    mousewheel: (event) ->
        if event.originalEvent.wheelDelta >= 0 and $(window).scrollTop() < window.core.state["scrolloff"]
            $("#waypoint-0").css position: "absolute"

expH = new ExperienceHandler()
window.core.registerScrollHandler "waypointfixer", ->
    expH.scroll()

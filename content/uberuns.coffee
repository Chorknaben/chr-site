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
        @waypoints = $( ".waypoint" )

    scrollDown: ->

hwpimg = $ ($ "#waypoint-0 img").offset()

$( "body" ).on
    mousewheel: (event) ->
        if event.originalEvent.wheelDelta >= 0 and $(window).scrollTop() < window.core.state["scrolloff"]
            $("#waypoint-0").css position: "absolute"

window.core.registerScrollHandler "waypointfixer", ->
    if $(window).scrollTop() > $(window).height() - 40 and not window.core.state["scrolledDown"]
        $("#waypoint-0").css position: "fixed"

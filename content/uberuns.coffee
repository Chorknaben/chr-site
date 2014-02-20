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
        if event.originalEvent.wheelDelta >= 0 and $(window).scrollTop() < SCROLLED_OFFSETY
            $("#waypoint-0").css position: "absolute"

scrollDelegates.push -> 
    $("#waypoint-0").css position: "fixed"

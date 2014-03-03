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
        @c.state["eingerastet"] = new Array(@waypoints.length)
        for i in [0..@waypoints.length - 1] 
            @c.state["eingerastet"][i] = false 
        #@c.state["eingerastet"][0] = true
        #todo
        #@c.state.reserve("eingerastet", {
        #    type: "Array(10)"
        #    init: false
        #})
        @topOnRast = -1
        @stack     = 0
        @cssOrgTop = 0
        @lastScroll = 0
        @originalTops = []
        for i in [0 .. @waypoints.length - 1]
            @originalTops.push(parseInt($(@waypoints[i]).css("top"))+$(window).height()-155)
        console.log @originalTops

    scroll: ->
        # EXPLANATION OF TERMINOLOGY
        # ---------------------
        #    --> Both Waypoints are referred to as a
        #        viewing context
        #   /--> $ stackFstC
        # (-) <Fixed Waypoint>  --> $ stackFst (DOM Element)
        #  |  | ------------- |
        #  |  | ------------- |
        #  |  lorem ipsum dolor --> $ stackFstB
        #  |  sit amet..        --> $ fstEdge (Int, y-position)
        #  |
        #  | --> $ fstDelta (Distance between both points)
        #  |
        # (-) <Scrolled Waypoint> --> $ stackSnd (DOM Element)
        #  |  | ------------- |   --> $ stackSndI (Dom Element, Image Container)
        #  |  | ------------- |
        #  |  lorem ipsum dolor
        #  |  sit amet..
        #  --------------------- 

        # stackFst is the Waypoint that is currently fixed and 
        # fully visible to the user
        stackFst  = $ @waypoints[@stack]
        stackFstB = stackFst.children('.wbody')
        stackFstC = stackFst.children('.connector')

        # Bottom Edge of the entire visible waypoint.
        fstEdge   = stackFstB.offset().top + stackFstB.height()

        # Height of entire Waypoint, 279 is y of constant DOM Elements
        stackHgt  = 279 + stackFstB.height()

        # stackSnd is the Waypoint that is scrolling upwards
        stackSnd  = $ @waypoints[@stack + 1]
        stackSndI = stackSnd.children('img')

        # Distance between both points
        fstDelta  = stackSndI.offset().top - fstEdge

        # When both waypoints aren't at the same position,
        # lessen the opacity of the <Fixed Waypoint> the more
        # the <Scrolled Waypoint> is going upwards
        #if fstDelta <= 0
        #    stackFst.css opacity: 1 - Math.abs(fstDelta) * (1 / stackHgt)

        #MAKE THIS CODE PRETTY PLEASE PLESASE PLESASE OMG OMG OMG MOST EMBARASSING GIT COMMIT EVER
        absolute = "absolute"
        fixed = "fixed"
        st = @w.scrollTop()
        if st > @lastScroll
            # down
            for i in [0..@waypoints.length - 1]
                if i is 0
                    if @w.scrollTop() < @originalTops[0]
                        $(@waypoints[0]).css position:absolute
                if @originalTops[i - 1] < @w.scrollTop() < @originalTops[i]
                    #opacity here 
                    $(@waypoints[i - 1]).css position:fixed, top:"150px"
                    #optimize and prettyfy this ffs!
                    distance = $(@waypoints[i]).children('img').offset().top - ($(@waypoints[i-1]).children('.wbody').offset().top + $(@waypoints[i-1]).children('.wbody').height())
                    asdstack = 279 + $(@waypoints[i-1]).children('.wbody').height()
                    $(@waypoints[i - 1]).css opacity: 1 - Math.abs(distance) * (1 / asdstack)
                    $(@waypoints[i]).css position:absolute
                if i is @waypoints.length - 1
                    if @originalTops[i] < @w.scrollTop()
                        $(@waypoints[i]).css position:fixed

        else
            for i in [0 .. @waypoints.length - 1]
                if i is 0
                    if @w.scrollTop() < @originalTops[0]
                        $(@waypoints[0]).css position:"absolute"
                if @originalTops[i - 1] < @w.scrollTop() < @originalTops[i]
                    #same opacity crap here yo!
                    $(@waypoints[i]).css position:"absolute", top:@originalTops[i]-$(window).height()+155
        @lastScroll = st
        #if stackFstC.height() is 0 and ((@c.state["eingerastet"][@stack-1] and not @c.state.eingerastet[@stack]) or @stack is 0 )
        #    fillWith = true
        #    for i in [0..@c.state["eingerastet"].length - 1]
        #        if not @c.state.eingerastet[i]
        #            fillWith = false
        #        @c.state.eingerastet[i] = fillWith
        #    @c.state["eingerastet"][@stack] = true
        #    @stack++
        #    console.log @c.state.eingerastet
        #    console.log "Raste nach Down:" + @stack
        #    @cssOrgTop = $(@waypoints[@stack]).css 'top'
        #    $(@waypoints[@stack]).css position:'fixed', top:'150px'
        #    $(@waypoints[@stack-1]).css position:'fixed', top:'150px'
        #    @topOnRast = $(window).scrollTop()
        #    return

        #if $(window).scrollTop() < @topOnRast and @c.state["eingerastet"][@stack-1] and not @c.state.eingerastet[@stack]
        #    for i in [0..@c.state["eingerastet"].length - 1]
        #        if not @c.state.eingerastet[i+1]
        #            @c.state.eingerastet[i] = false
        #            break
        #        @c.state.eingerastet[i] = true

        #    $(@waypoints[@stack]).css position:'absolute', top:@cssOrgTop
        #    @stack--
        #    console.log "Chill0rze nach up: " + @stack
        #    console.log @c.state.eingerastet
        #    #console.log @stack
        #    #todo messed up here
        #    #stackSnd.css position:'absolute', top:@cssOrgTop
        #    # see above dis not yet updated technically stackSnd yo
        #    return

    fitConnectors: =>
        @waypoints.each (index, obj) =>
            if index is @waypoints.length - 1 then return
            obj     = $(obj)
            connect = obj.children('.connector')
            nextImg = $(@waypoints[index + 1]).children('img')
            connect.css
                height: nextImg.offset().top - connect.offset().top + 8

    #onScrollUpwards: ->
    #    $(@waypoints[@stack]).css position: "absolute"
            
expH = new ExperienceHandler()
$( "body" ).on
    mousewheel: (event) ->
        if event.originalEvent.wheelDelta >= 0 and $(window).scrollTop() < window.core.state["scrolloff"]
            $("#waypoint-0").css position: "absolute"

window.core.registerScrollHandler "waypointfixer", ->
    expH.scroll()
    expH.fitConnectors()

class Tile
    constructor: (@tileid, @const=Constants) ->
        @core = window.core
        @interval = null
        @scaleCount = 0
        @headerImg = $("#header-img")

    onClick: =>
        console.log "Tile Click: id=#{@tileid}"
        if @tileid > 7 then @tileid -= 7
        console.log @const.tileResolver
        @load(
           @const.tileResolver[@tileid-1][0],
           @const.tileResolver[@tileid-1][1]
        )

    load: (prettyWhat, urlWhat) ->
        # Animations happening on Click
        # --------
        @interval = setInterval @sclSmaller, 10
        setTimeout @activateLoadingAnimation, 30
        @navigationDown()

        # Load content
        # --------
        $("#result").load "content/#{ urlWhat }.html", =>
            window["load_#{ urlWhat }"]()
            window.location.hash = urlWhat
            $(".scrolled").attr("id", urlWhat)
            @core.state["currentPage"] = prettyWhat
            @core.state["currentURL" ] = urlWhat
            @core.state["tileid"] = @tileid
            @core.registerTaker("pageChanged", true)
            $.getScript "content/#{ urlWhat }.js"
                .done =>
                    $.scrollTo ".scrolled", 800, onAfter: =>
                        @core.state["scrolloff"  ] = $(window).scrollTop()

                        # Change Title and fade in
                        $(".ctitle").html("Chorknaben // #{ prettyWhat }")
                        $(".ctitle").fadeTo(200, 1)

                        # Revert state that animations modified
                        $("#loading-img").css visibility:"hidden"
                        $("#header-img").width(90)
                        @scaleCount = 0
        $(".ctitle").fadeTo(200, 0)

    sclSmaller: =>
        if @scaleCount >= 20
            window.clearInterval(@interval)
            return
        @scaleCount++
        @headerImg.width(90 - @scaleCount)

    activateLoadingAnimation: ->
        $("#loading-img").css visibility: "visible"

    navigationDown: ->
        navItems = $('.header-nav').children('a')
        currentN = $(navItems[@tileid - 1])
        currentN.animate({top: '65px'}, 800)

        spans = $('.header-nav').children('span')
        currentSpan = $(spans[@tileid - 1])
        if currentSpan isnt undefined
            currentSpan.animate({opacity:'0'}, 800)


`
function withResponseObject(url, callback){
    $.ajax({
        url:url,
    })
      .done(function(data){
        callback(JSON.parse(data));   
    });
}
window["load_bilder"] = function(){
    
    console.log("entered bilder");
    withResponseObject("/images/num", function(retobj){
         var tcolcount = 0;    
         for(var i = 0; i <= Math.ceil(retobj.numtiles / 5); i++){
            $("#scrolledcontentoff").append(
                "<div class=\"tile-column\" id=\"imgcol-"+ i +"\"></div>"
            );
            for (var x = 0; x <= 4; x++){
                $("#imgcol-"+i).append(
                    $("<div>").addClass("stdtile m10 x-"+x).append(
                        $("<div>").addClass("tile-scaling"),
                        $("<div>").addClass("tile-content test-b").append(
                            $("<a>").attr("href", "#").append(
                                $("<div>").addClass("image-thumb")
                            )
                        )
                    )
                );
            }
            $("#scrolledcontentoff").pullupScroll("#scrolledcontentoff .tile-column");
         }
    });
}
window["load_uberuns"] = function(){
    
}
`

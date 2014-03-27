class Uberuns extends ChildPage
    constructor: ->

    onLoad: ->
        $(".icon-container .hoveroverlay").each (i, obj) ->
            $obj = $(obj)
            $obj.hover(->
                $obj.animate({opacity: 0.7}, 100)
            , ->
                $obj.animate({opacity: 0}, 100)
            )

        $(".testblock").hover(->
            $(this).animate({opacity:0}, 350)
        ,->
            $(this).animate({opacity:1}, 350)
        )

    mouseEnter: ->


window.core.insertChildPage(new Uberuns())

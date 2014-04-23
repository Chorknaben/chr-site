class Uberuns extends ChildPage
    constructor: ->

    onLoad: ->
        $(".testblock").hover(->
            setTimeout( ->
                if $(".testblock").is(":hover")
                    $(".testblock").animate({opacity:0}, 350)
            , 700)
        ,->
            $(this).animate({opacity:1}, 350)
        )

    mouseEnter: ->


window.core.insertChildPage(new Uberuns())

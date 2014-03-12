class Bilder extends ChildPage
    constructor: ->
        super()

    onGenerateMarkup: ->
        @c.withAPICall "/images/num", (retobj) ->
             tcolcount = 0
             for i in [0 .. Math.ceil(retobj.numtiles / 5)]
                $("#scrolledcontentoff").append(
                    "<div class=\"tile-column\" id=\"imgcol-#{i}\"></div>"
                )
                for x in [0..4]
                    $("#imgcol-"+i).append(
                        $("<div>").addClass("stdtile m10 x-#{x}").append(
                            $("<div>").addClass("tile-scaling"),
                            $("<div>").addClass("tile-content test-b").append(
                                $("<a>").attr("href", "#").append(
                                    $("<div>").addClass("image-thumb")
                                )
                            )
                        )
                    )
                $("#scrolledcontentoff").pullupScroll "#scrolledcontentoff .tile-column"

    onLoad: ->
        # Once the generated Class exists, add background images to it
        # Complete redesign pending
        window.dirtyhack = setInterval( ->
            if $('.image-thumb').length isnt 0
                window.clearInterval(window.dirtyhack)
                $('.image-thumb').each (i, obj) ->
                    $(obj).css({"background-image":"url(/images/thumbs/#{i+1})"})
        , 100)

    onScrollFinished: ->
        @c.registerScrollHandler "pullup", ->
            $(".pullup-element").each (i, el) ->
                el = $(el)
                if (el.visible(true))
                    el.addClass("come-in")

    onUnloadChild: ->
        @c.deleteScrollHandler "pullup"


window.core.insertChildPage(new Bilder())

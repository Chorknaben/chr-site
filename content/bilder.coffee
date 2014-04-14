class Bilder extends ChildPage
    constructor: ->
        super()

    onGenerateMarkup: ->
        @c.withAPICall "/images/num", (retobj) ->

    onDOMVisible: ->
        @adjustPos()
        $(window).bind
            resize: @adjustPos

    adjustPos: =>
        #Adjust the positioning of the image grid to be centered exactly.
        width = $(window).width()
        rightElem = @findRightMost()
        rightPoint = rightElem.offset().left + rightElem.width()
        delta = (width * 0.94 - rightPoint) / 2

        $(".image-container").css "margin-left" : (width * 0.06) + delta

    findRightMost: ->
        firstOffset = $(".img-image").first().offset().top
        leftIndex   = -1
        console.log "First offset:" + firstOffset
        console.log $(".img-image")
        $(".img-image").each (index, obj) =>
            $obj = $(obj)
            if $obj.offset().top isnt firstOffset
                leftIndex = index - 1
                return false
        if leftIndex isnt -1
            return $(".img-image").eq(leftIndex)
        return false

    onUnloadChild: ->
        $(window).unbind("resize", @adjustPos)
                

window.core.insertChildPage(new Bilder())

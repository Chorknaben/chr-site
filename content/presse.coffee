class Presse extends ChildPage
    @ready = false
    @wall  = null
    constructor: ->
        super()

    onGenerateMarkup: ->

    onLoad: ->
        $(".scrolled").css "background-image" : "url(img/testbg1920gauss.png)"
        $.getScript "code/sly.min.js", ->
            sly = new Sly(".presse-frame", {
                horizontal: 1
                itemNav:    'basic'
                activateOn: 'click'
                mouseDragging: 1
                touchDragging: 1
                releaseSwing: 1
                smart: 1
                dynamicHandle: 1
                speed: 300
                easing: 'swing'
                scrollBy:   1
            }).init()
            $(".presse-frame").css top: $(window).height()/2 - $(".presse-frame").height()/2


    onScrollFinished: ->

    onUnloadChild: ->


window.core.insertChildPage(new Presse())

class Musik extends ChildPage
    constructor: ->
        super()
        @core = window.core
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

    acquireLoadingLock: ->
        return true

    onLoad: ->
        @core.setMetaDesc("Hauptsache: Musik.", "Musik")
        if window.ie
            attr = $(".cd img").attr("src")
            $(".cd img").attr("src", attr + ".png")
        $.when(
            $.getScript("/code/audio.min.js"),
            $.Deferred (deferred) ->
                $(deferred.resolve)
        ).done( =>
            audiojs.events.ready =>
                @audi = audiojs.createAll()[0]
                window.core.release()
        ) 

    onDOMVisible: ->
        $.ajax({
            url: "/data/json/musik.json"
        }).done (json) =>
            for file in json.musik
                @addMusicFile(file.displayname, file.pathname)
            @clickEvents(@audi)
            @selectFirst(@audi)


    addMusicFile: (display, path) ->
        parent = $(".playlist")
        parent.append(
            $("<li>").attr("data-src", path).append(display))

    selectFirst: (audiojs) ->
        first = $(".playlist li").first()
        first.addClass("playing")

        audiojs.load("/data/musik/" + first.attr("data-src"))

    clickEvents: (audiojs) ->
        $(".playlist li").click (e) ->
            e.preventDefault()
            $(@).addClass('playing').siblings().removeClass('playing')

            audiojs.load("/data/musik/" + $(@).attr("data-src"))
            audiojs.play()


window.core.insertChildPage(new Musik())

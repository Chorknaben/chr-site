class Musik extends ChildPage
    constructor: ->
        super()
        @core = window.core
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()
        console.log @contentViewer

    onLoad: ->
        if window.ie
            attr = $(".cd img").attr("src")
            $(".cd img").attr("src", attr + ".png")

    onDOMVisible: ->
        audio = document.getElementsByTagName('audio')
        if audio[0] is null
            #neces?
            setTimeout(@onDOMVisible, 200)
            return

        audi = audiojs.create(audio[0])

        $.ajax({
            url: "/data/json/musik.json"
        }).done (json) =>
            for file in json.musik
                @addMusicFile(file.displayname, file.pathname)
            @clickEvents(audi)
            @selectFirst(audi)


    addMusicFile: (display, path) ->
        parent = $(".playlist")
        parent.append(
            $("<li>").attr("data-src", path).append(display))

    selectFirst: (audiojs) ->
        first = $(".playlist li").first()
        first.addClass("playing")
        console.log first

        audiojs.load("/data/musik/" + first.attr("data-src"))

    clickEvents: (audiojs) ->
        $(".playlist li").click (e) ->
            e.preventDefault()
            $(@).addClass('playing').siblings().removeClass('playing')

            audiojs.load("/data/musik/" + $(@).attr("data-src"))
            audiojs.play()


window.core.insertChildPage(new Musik())

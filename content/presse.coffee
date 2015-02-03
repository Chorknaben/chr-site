class Presse extends ChildPage
    constructor: ->
        super()
        @articleCount = 1
        @c.requestFunction "ImageViewer.requestInstance",
            (imgView) => @imageViewer = imgView()

    acquireLoadingLock: ->
        return true

    notifyHashChange: (hash) ->
        if hash.lastIndexOf("/artikel/",0) is 0
            id = parseInt(hash.substr(9, hash.length))
            if window.ie 
                @imageViewer.open
                    imagesource: "/data/presse/real/#{id-1}"
                    handleImageLoading: true
                    navigation: true
                    minImage: 1
                    maxImage: @articleCount
                    arrowKeys: true
                    getCurrentElement: ->
                        h = location.hash
                        parseInt h.substr(h.lastIndexOf("/") + 1, h.length)
                    toLeftHash: (currentEl) ->
                        "#!/presse/artikel/#{currentEl-1}"
                    toRightHash: (currentEl) ->
                        "#!/presse/artikel/#{currentEl+1}"
                    escapeKey: true
                    lockScrolling: true
                    revertHash: "#!/presse"
                    enableDragging: true
                    descriptionSetting: 1
            else
                img = $("<img>").bind("load", =>
                        @imageViewer.open
                            image: img
                            navigation: true
                            minImage: 1
                            maxImage: @articleCount
                            arrowKeys: true
                            getCurrentElement: ->
                                h = location.hash
                                parseInt h.substr(h.lastIndexOf("/") + 1, h.length)
                            toLeftHash: (currentEl) ->
                                "#!/presse/artikel/#{currentEl-1}"
                            toRightHash: (currentEl) ->
                                "#!/presse/artikel/#{currentEl+1}"
                            escapeKey: true
                            lockScrolling: true
                            revertHash: "#!/presse"
                            enableDragging: true
                            descriptionSetting: 1
                    ).attr("src","/data/presse/real/#{id-1}")

    onDOMVisible: ->
        @adjustPos()
        $(window).on("resize", @adjustPos)

    onUnloadChild: ->
        window.core.revMetaDesc()
        $(window).off("resize", @adjustPos)
        # TODO: Investigate: put @imageViewer.close(true) here
        $(".image-viewer").addClass("nodisplay")
        $("#image-viewer-exit-button").addClass("nodisplay")
        #@imageViewer.close(true)

    onLoad: ->
        window.core.setMetaDesc("Aktuelle News", "News")
        $.ajax({
            url: "/data/json/presse.json"
        }).done (tree) =>
            console.log tree
            for article in tree.presse
                @genArticle(article)
            @c.release()

    genArticle: (article) ->
        $(".presse-container").append(
            $("<a>").addClass("img-presse").attr("href","/#!/presse/artikel/#{@articleCount}")
                .append($("<div>").addClass("presse-date").html(article.date))
                .append($("<img>").addClass("deadcenter").attr("src","/data/presse/thumbs/#{@articleCount-1}"))
                .append($("<span><h1>#{article.name}</h1>#{article.caption}</span>"))
        )
        @articleCount++

    adjustPos: =>
        #Adjust the positioning of the image grid to be centered exactly.
        width = $(window).width()

        selPress = $(".img-presse")

        vertAxis = width / 2

        totalWidth = selPress.width()
        if selPress.eq(0).offset().top == selPress.eq(1).offset().top
            # If two elements are displayed next to each other
            totalWidth += selPress.width() + 10

        distanceFromLeft = vertAxis - (totalWidth / 2)
        $(".presse-container").css "padding-left" : distanceFromLeft

window.core.insertChildPage(new Presse())

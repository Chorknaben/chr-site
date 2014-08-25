class Presse extends ChildPage
    constructor: ->
        super()
        @articleCount = 1
        @c.requestFunction "ImageViewer.requestInstance",
            (imgView) => @imageViewer = imgView()

    acquireLoadingLock: ->
        return true

    notifyHashChange: (hash) ->
        console.log("notifyHashChange")
        if hash.lastIndexOf("/artikel/",0) is 0
            id = parseInt(hash.substr(9, hash.length))
            console.log("notifyHashChange2")
            img = $("<img>").bind("load", =>
                    console.log("ohai my schatzipitz")
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
                ).attr("src","/img/presse#{id-1}.jpg")

    onDOMVisible: ->
        @adjustPos()
        $(window).on("resize", @adjustPos)

    onUnloadChild: ->
        $(window).off("resize", @adjustPos)
        # TODO: Investigate: put @imageViewer.close(true) here
        $(".image-viewer").addClass("nodisplay")
        #@imageViewer.close(true)

    onLoad: ->
        $.ajax({
            url: "presse.json"
        }).done (tree) =>
            console.log tree
            for article in tree.presse
                @genArticle(article)
            @c.release()

    onScrollFinished: ->

    genArticle: (article) ->
        $(".presse-container").append(
            $("<a>").addClass("img-presse").attr("href","/#!/presse/artikel/#{@articleCount}")
                .append($("<img>").addClass("deadcenter").attr("src",article.url))
                .append($("<span><h1>#{article.name}</h1>#{article.caption}</span>"))
        )
        @articleCount++

    adjustPos: =>
        #Adjust the positioning of the image grid to be centered exactly.
        width = $(window).width()
        rightElem = @findRightMost()
        rightPoint = rightElem.offset().left + rightElem.width()
        delta = (width * 0.94 - rightPoint) / 2

        $(".presse-container").css "margin-left" : (width * 0.06) + delta

    findRightMost: ->
        try
            firstOffset = $(".img-presse").first().offset().top
            leftIndex   = -1
            $(".img-presse").each (index, obj) =>
                $obj = $(obj)
                if $obj.offset().top isnt firstOffset
                    leftIndex = index - 1
                    return false
            if leftIndex isnt -1
                return $(".img-presse").eq(leftIndex)
            return false
        catch error
            return false


window.core.insertChildPage(new Presse())

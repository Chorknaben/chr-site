class Bilder extends ChildPage
    constructor: ->
        super()
        @catCount = 0
        @core = window.core
        @minImage = 0
        @maxImage = -1

        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

        @core.requestFunction "ImageViewer.requestInstance",
            (imgView) => @imageViewer = imgView()

    isCategory: (newHash) ->

    notifyHashChange: (newHash) ->
        # Bilder hat 2 Funktionen: /element/ und /category/.
        # Beide können in externen Links oder als onclick-events
        # referenziert werden.

        if newHash.indexOf("/element/") == 0
            id = parseInt(
                    newHash.substr(
                            9, newHash.length
                        )
                )
            console.log "executing"
            for elem in $("a")
                if elem.getAttribute("href") is "/#!/bilder#{newHash}"
                    el = $(elem)
                    break
            el.addClass("loading")
            if window.ie
                # Internet Explorer 8 benötigt ein paar Ausnahmen in punkto
                # Bildlademechanismen... siehe Handling des imagesource Attributs
                # in der ImageViewer Klasse.
                @imageViewer.open
                    imagesource: "/images/real/#{id}"
                    handleImageLoading: true
                    navigation: true
                    minImage: @minImage
                    maxImage: @maxImage
                    arrowKeys: true
                    getCurrentElement: ->
                        h = location.hash
                        parseInt h.substr(h.lastIndexOf("/") + 1, h.length)
                    toLeftHash: (currentEl) ->
                        "#!/bilder/element/#{currentEl-1}"
                    toRightHash: (currentEl) ->
                        "#!/bilder/element/#{currentEl+1}"
                    escapeKey: true
                    lockScrolling: true
                    revertHash: "#!/bilder"
            else
                # Die beste Möglichkeit, ein Bild im ImageViewer ordnungsgemäß zu
                # öffnen. In dieser Variante sind Ladeanimation on prefetch dabei.
                image = $("<img>").attr("src", "/images/real/#{id}")
                    .load =>
                        el.removeClass("loading")
                        @imageViewer.open
                            image: image
                            title: @id2title(id)
                            positionInChapter: @posInChapter(id).toString()
                            chapterTotalLength: @chapterTotalLength(id).toString()
                            nextChapterScreen: true
                            chapterID: @id2chapID(id)
                            chapterName: @chapterInfo(id)
                            navigation: true
                            minImage: @minImage
                            maxImage: @maxImage
                            arrowKeys: true
                            getCurrentElement: ->
                                h = location.hash
                                parseInt h.substr(h.lastIndexOf("/") + 1, h.length)
                            toLeftHash: (currentEl) ->
                                "#!/bilder/element/#{currentEl-1}"
                            toRightHash: (currentEl) ->
                                "#!/bilder/element/#{currentEl+1}"
                            escapeKey: true
                            lockScrolling: true
                            revertHash: "#!/bilder"

            $("#arrow-container").removeClass("nodisplay")
            return

        if newHash.indexOf("/kategorie/") == 0
            # Eine Kategorie wurde geklickt oder referenziert.
            # Es gibt 2 Möglichkeiten des Kontexts:
            #    1) Wir befinden uns IM Imageviewer, sind beim ersten oder letzten Bild einer
            #       Kategorie und wechseln mit einem klick nach rechts oder links die Kategorie
            #    2) Wir wurden von einer externen Seite auf diese Kategorie weitergeleitet
            #       oder klicken auf die Kategorie
            if @imageViewer.state is @imageViewer.OPEN
                @imageViewer.close()

            # Für den Fall, die Kategorie wird extern aufgerufen
            @adjustPos()

            # Positionierungsvariablen
            rightElem = @findRightMost()
            rightPt = rightElem.offset().left + rightElem.width()
            firstChapt = $(".image-container").children().eq(0).offset()

            # chapterID is either a number or a name
            chapterID = newHash.substr(11,newHash.length)
            if chapterID.indexOf("by-title/") == 0
                counter = 0
                for category in @tree
                    cTitle = category.category.title.toLowerCase().replace(" ", "-")
                    inTitle = chapterID.substr(9, chapterID.length).toLowerCase().replace(" ", "-")
                    console.log cTitle
                    console.log inTitle
                    if cTitle == inTitle
                        break
                    counter++
                chapterID = counter
                console.log chapterID


            # Das Chapter Element
            chapter = $(".img-chapter").eq(chapterID)

            unless chapterID is 0
                $(".arrleft").removeClass("arrow-inactive")

                previousAttr = chapter.prev().attr("href")
                $(".arrleft").attr("href", previousAttr)
            else
                $(".arrleft").addClass("arrow-inactive")

            unless chapterID is @catCount
                $(".arrleft").removeClass("arrow-inactive")

                nextAttr = chapter.next().attr("href")
                $(".arrright").attr("href", nextAttr)
            else
                $("arrleft").addClass("arrow-inactive")

            @contentViewer.open
                left:  -> firstChapt.left
                top:   -> firstChapt.top
                right: -> $(window).width() - rightPt + 30
                height:-> "100%"
                scrollTo: chapter
                title: @tree[chapterID].category.title
                caption: @tree[chapterID].category.caption
                revertHash: "#!/bilder"
                content: @tree[chapterID].category.content
                animate: false

            $("#arrow-container").removeClass("nodisplay")

    id2title: (id) ->
        for category in @tree
            for imgpair in category.category.childs
                if imgpair[0] == id
                    console.log imgpair[1]
                    return imgpair[1]

    id2chapID: (id) ->
        counter = 0
        for category in @tree
            for imgpair in category.category.childs
                if imgpair[0] == id
                    return counter
            counter++

    posInChapter: (id) ->
        for category in @tree
            counter = 0
            for imgpair in category.category.childs
                if imgpair[0] == id
                    return counter + 1
                counter++

    chapterTotalLength: (id) ->
        for category in @tree
            for imgpair in category.category.childs
                if imgpair[0] == id
                    return category.category.childs.length

    chapterInfo: (id) ->
        for category in @tree
            for imgpair in category.category.childs
                if imgpair[0] == id
                    return [category.category.title, category.category.caption, category.category.content]

    acquireLoadingLock: ->
        # Wir müssen erst mal die Bilderstruktur generieren.
        return true

    onLoad: =>
        # Inhalte Generieren.
        $.ajax({
            url: "/data/json/bilder.json"
        }).done (tree) =>
            @tree = tree
            for c in tree
                @genCat(c.category.title, c.category.caption, c.category.content)
                for imgptr in c.category.childs
                    @genImg(imgptr[0], imgptr[1])
                    @maxImage++
            @c.release()
            

    onDOMVisible: ->
        @adjustPos()
        $(window).on("resize", @adjustPos)

    onUnloadChild: ->
        $(window).off("resize", @adjustPos)
        $(".image-viewer").addClass("nodisplay")


    adjustPos: =>
        # Diese Funktion sorgt dafür, dass die Kacheln immer zentriert sind.
        # TODO: Pure CSS Lösung, wenigstens auf Browsern die es unterstützen.
        width = $(window).width()
        rightElem = @findRightMost()
        rightPoint = rightElem.offset().left + rightElem.width()
        delta = (width * 0.94 - rightPoint) / 2

        $(".image-container").css "margin-left" : (width * 0.06) + delta

    findRightMost: ->
        # Hilfsfunktion adjustPos
        try
            firstOffset = $(".img-image").first().offset().top
            leftIndex   = -1
            $(".img-image").each (index, obj) =>
                $obj = $(obj)
                if $obj.offset().top isnt firstOffset
                    leftIndex = index - 1
                    return false
            if leftIndex isnt -1
                return $(".img-image").eq(leftIndex)
            return false
        catch error
            return false

    genCat: (title, caption, content) ->
        $(".image-container").append(
            $("<a>").addClass("img-chapter").attr("href","/#!/bilder/kategorie/#{@catCount}").append(
                $("<h2>#{title}</h2>").append(
                    $("<span>#{caption}</span>")
                )
            )
        )
        @catCount++

    genImg: (filePtr, caption) ->
        $(".image-container").append(
            $("<a>").addClass("img-image").attr("href","/#!/bilder/element/#{filePtr}")
                .append($("<img>").attr("src","/images/thumbs/#{filePtr}"))
                .append($("<span>#{caption}</span>"))
        )

window.core.insertChildPage(new Bilder())

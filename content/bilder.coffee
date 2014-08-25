class Bilder extends ChildPage
    constructor: ->
        super()

        @catCount = 0
        @currentScrollPos = -1

        @core = window.core
        @contentViewer = null
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

        @core.requestFunction "ImageViewer.requestInstance",
            (imgView) => @imageViewer = imgView()
            
        @timeout = null

        @minImage = 1
        @maxImage = 0

    notifyHashChange: (newHash) ->
        if newHash.indexOf("/element/") == 0
            id = parseInt(newHash.substr(9,newHash.length))
            elems = $("a")
            el = undefined
            for elem in elems
                if elem.getAttribute("href") is "/#!/bilder#{newHash}"
                    el = $(elem)
                    break
            el.addClass("loading")
            if window.ie
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
                image = $("<img>").attr("src", "/images/real/#{id}")
                    .load =>
                        el.removeClass("loading")
                        @imageViewer.open
                            image: image
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

        if newHash.indexOf("/kategorie/") == 0
            rightElem = @findRightMost()
            rightPt = rightElem.offset().left + rightElem.width()
            firstChapt = $(".image-container").children().eq(0).offset()
            chapterID = newHash.substr(11,newHash.length)
            chapter = $(".img-chapter").eq(chapterID)
            @contentViewer.open
                left:  -> firstChapt.left
                top:   -> firstChapt.top
                right: -> $(window).width() - rightPt + 30
                height:-> "100%"
                scrollTo: chapter
                title: "WILLKOMMEN"
                caption: "auf unserer Bilder Seite!"
                revertHash: "#!/bilder"
                content: "<p>Prosciutto sirloin filet mignon pancetta. Rump frankfurter tail, fatback cow tenderloin ham hock. Strip steak meatball beef shank doner jowl turducken bacon t-bone biltong salami. Prosciutto meatball pancetta filet mignon brisket ham jowl sirloin. Biltong ground round brisket, sirloin tail corned beef pig pork chop ball tip shoulder beef ribs frankfurter beef pork salami.</p>"
                animate: false

    onLoad: =>
        # Generate content
        $.ajax({
            url: "test.json"
        }).done (tree) =>
            for c in tree
                @genCat(c.category.title, c.category.caption, c.category.content)
                for imgptr in c.category.childs
                    @genImg(imgptr[0], imgptr[1])
                    @maxImage++
            @c.release()
            
    acquireLoadingLock: ->
        return true

    onDOMVisible: ->
        @adjustPos()
        $(window).on("resize", @adjustPos)

    onUnloadChild: ->
        $(window).off("resize", @adjustPos)
        $(".image-viewer").addClass("nodisplay")


    adjustPos: =>
        #Adjust the positioning of the image grid to be centered exactly.
        width = $(window).width()
        rightElem = @findRightMost()
        rightPoint = rightElem.offset().left + rightElem.width()
        delta = (width * 0.94 - rightPoint) / 2

        $(".image-container").css "margin-left" : (width * 0.06) + delta

    findRightMost: ->
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

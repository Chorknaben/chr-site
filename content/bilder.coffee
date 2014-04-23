class Bilder extends ChildPage
    constructor: ->
        @catCount = 0
        @currentScrollPos = -1
        super()

    notifyHashChange: (newHash) ->
        console.log newHash
        if newHash.indexOf("/element/") == 0
            id = parseInt(newHash.substr(9,newHash.length))
            console.log "id:#{id}"
            el = $(".img-image").eq(id-1)
            console.log el
            el.addClass("loading")
            image = $("<img>").attr("src", "/images/real/#{id}")
                .load =>
                    el.removeClass("loading")
                    @imageViewerOpen(image)
        if newHash.indexOf("/kategorie/") == 0
            rightElem = @findRightMost()
            rightPt = rightElem.offset().left + rightElem.width()
            firstChapt = $(".image-container").children().eq(0).offset()
            chapterID = newHash.substr(11,newHash.length)
            chapter = $(".img-chapter").eq(chapterID)
            @contentViewerOpen
                left: firstChapt.left
                top: firstChapt.top
                right: $(window).width() - rightPt
                chapter: chapter
                title: "WILLKOMMEN"
                caption: "auf unserer Bilder Seite!"
                content: "<p>Prosciutto sirloin filet mignon pancetta. Rump frankfurter tail, fatback cow tenderloin ham hock. Strip steak meatball beef shank doner jowl turducken bacon t-bone biltong salami. Prosciutto meatball pancetta filet mignon brisket ham jowl sirloin. Biltong ground round brisket, sirloin tail corned beef pig pork chop ball tip shoulder beef ribs frankfurter beef pork salami.</p>"

    onLoad: =>
        # Generate content
        $.ajax({
            url: "test.json"
        }).done (tree) =>
            console.log "onLoad: Generating Content!"
            for c in tree
                @genCat(c.category.title, c.category.caption, c.category.content)
                for imgptr in c.category.childs
                    @genImg(imgptr[0], imgptr[1])
            @c.release()
            
    acquireLoadingLock: ->
        return true

    onDOMVisible: ->
        @adjustPos()
        $(window).bind
            resize: @adjustPos

    onUnloadChild: ->
        $(window).unbind("resize", @adjustPos)

    contentViewerOpen: (contentObj) =>
        $cnt = $(".content-viewer")
        #todo click another while open? think about that bitch..
        console.log "contentViewer: open"

        #$.scrollTo("+=#{contentObj.chapter.offset().top-contentObj.top}px", 200)
        $.scrollTo(contentObj.chapter.offset().top-contentObj.top, 500)

        $("html").css cursor:"pointer"
        $cnt.css
            left: contentObj.left
            right: contentObj.right+30
            top: contentObj.top
            cursor:"default"

        $cnt.children("h1").html(contentObj.title)
        $cnt.children("h2").html(contentObj.caption)
        $cnt.children("#ccnt").html(contentObj.content)

        $(document).click @closeClickHandler
        $(".content-viewer").click @clickOnViewerHandler

        $cnt.removeClass("nodisplay")

    closeClickHandler: =>
        @contentViewerClose()

    clickOnViewerHandler: (event) =>
        event.stopPropagation()

    contentViewerClose: =>
        $cnt = $(".content-viewer")
        console.log "contentViewer: close"

        $(document).unbind("click", @closeClickHandler)
        $(".content-viewer").unbind("click", @clickOnViewerHandler)

        $("html").css cursor: "default"
        $cnt.css cursor: "default"

        @c.registerTaker("dontHandle", true)
        window.location.hash = "#!/bilder"

        $cnt.addClass("nodisplay")

    imageViewerOpen: (image) =>
        #lock scrolling
        @currentScrollPos = $(window).scrollTop()
        console.log "recording current scrolltop:"
        $(".scrolled").css overflow:"hidden"

        viewer = $(".image-viewer")
        $(image).addClass("link-cursor")
        $(image).click =>
            @imageViewerClose()
        $(image).prependTo($(".image-viewer"))
        viewer.removeClass("nodisplay")
        $(".cross").removeClass("nodisplay")

    imageViewerClose: =>
        #revert Scrolling
        console.log @currentScrollPos
        $(".scrolled").css overflow:"initial"
        $(window).scrollTop(@currentScrollPos)

        #revert hash
        @c.registerTaker("dontHandle", true)
        window.location.hash = "#!/bilder"

        #close viewer
        $(".image-viewer").addClass("nodisplay")
        $(".image-viewer").children("img").remove()
        $(".cross").addClass("nodisplay")
                
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

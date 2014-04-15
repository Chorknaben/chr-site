class Bilder extends ChildPage
    constructor: ->
        @catCount = 0
        @currentScrollPos = -1
        super()

    argumentHandler: ->
        #When delegated something like /bilder/elements/15
        #important! todo!

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
            
            # Initialize onclick listeners
            @initOnClick()

    acquireLoadingLock: ->
        return true

    onDOMVisible: ->
        @adjustPos()
        $(window).bind
            resize: @adjustPos

    onUnloadChild: ->
        $(window).unbind("resize", @adjustPos)

    initOnClick: ->
        $(".img-image").each (index,obj) =>
            $obj = $(obj)
            $obj.click =>
                # Display loading spinner
                $obj.addClass("loading")

                # Load Image
                imgFullPath = $obj.children("img").attr("src").replace("thumbs","real")
                image = $("<img>").attr("src", imgFullPath)
                    .load =>
                        $obj.removeClass("loading")
                        @imageViewerOpen(image)

        $(".cross").click @imageViewerClose

    imageViewerOpen: (image) =>
        #lock scrolling
        @currentScrollPos = $(window).scrollTop()
        console.log "recording current scrolltop:"
        $(".scrolled").css overflow:"hidden"

        viewer = $(".image-viewer")
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

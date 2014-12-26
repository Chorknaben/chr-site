class Shop extends ChildPage
    constructor: ->
        super()

        window.core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

        @mode = ""

    onLoad : ->
    	$(".button").click ->
    		@contentViewer.close()
    		@contentViewer.reset()


    notifyHashChange: (newHash) ->
    	if newHash is "/cd" or newHash is "/dvd"
    		@contentViewer.reset()

    		btnMehrInfo = $("."+newHash.substring(1))

	    	@mode = newHash
	    	bothtiles = $(".unterstutzen-tile")
	    	@contentViewer.open
	            left:  -> $(bothtiles[0]).offset().left
	            top:   -> $(bothtiles[0]).offset().top
	            height:-> $(bothtiles[1]).height()
	            width: -> 1010
	            title: "Unsere " + @mode.substring(1).toUpperCase()
	            caption: "Mehr Informationen"
	            revertHash: "#!/shop"
	            content: (->
	            		if newHash is "/cd"
	            			$("#contentviewwrapper #cd").html()
	            		else if newHash is "/dvd"
	            			$("#contentviewwrapper #dvd").html()
	            	)()
	            animate: true
	            startingPos:
	            	left: btnMehrInfo.offset().left
	            	top:  btnMehrInfo.offset().top
	            	height: btnMehrInfo.height()
	            	width: btnMehrInfo.width()

    	$("a.wrapping").click (e) =>
    		e.preventDefault()
    		e.stopPropagation()
    		@contentViewer.close()
    		location.href = "#!/musik"




window.core.insertChildPage(new Shop())

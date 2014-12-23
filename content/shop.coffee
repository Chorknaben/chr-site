class Shop extends ChildPage
    constructor: ->
        super()

        window.core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()

        @mode = ""


    notifyHashChange: (newHash) ->
    	if newHash is "/cd" or newHash is "/dvd"
    		console.log "ohai"
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
	            content: $("#contentviewwrapper").html()
	            animate: false


window.core.insertChildPage(new Shop())

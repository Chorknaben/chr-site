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

    notifyHashChange: (newHash) ->
        console.log newHash
        if newHash is "/programm"

            elem = $(".main-area")
            offs = elem.offset()
            @contentViewer.open
                left:   -> elem.left
                top:    -> $(".main-area").offset().top - 100
                height: -> $(".offsetwrapper").height() + 250
                width:  -> 1000
                chapter: false
                title: "Was singen die Chorknaben?"
                caption: "Eine grobe &Uuml;bersicht unseres Repertoires."
                revertHash: "#!/musik"
                content: "<p>Prosciutto sirloin filet mignon pancetta. Rump frankfurter tail, fatback cow tenderloin ham hock. Strip steak meatball beef shank doner jowl turducken bacon t-bone biltong salami. Prosciutto meatball pancetta filet mignon brisket ham jowl sirloin. Biltong ground round brisket, sirloin tail corned beef pig pork chop ball tip shoulder beef ribs frankfurter beef pork salami.</p><ul class=\"musik-werke\"><li>Dieses Werk</li><li>Dieses Werk</li><li>Dieses Werk</li><li>Dieses Werk</li><li>Dieses Werk</li></ul>"
                animate: true
                startingPos:
                    left: offs.left
                    top: offs.top
                    width: elem.width()
                    height: elem.height()



window.core.insertChildPage(new Musik())

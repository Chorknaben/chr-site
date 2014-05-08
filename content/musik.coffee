class Musik extends ChildPage
    constructor: ->
        super()
        @core = window.core
        @core.requestFunction "ContentViewer.requestInstance",
            (cView) => @contentViewer = cView()
        console.log @contentViewer

    notifyHashChange: (newHash) ->
        console.log newHash
        if newHash is "/programm"
            @contentViewer.open
                left: $(".main-area").offset().left
                top: $(".main-area").offset().top
                right: $(window).width() - ($(".musik-dimension").offset().left + $(".musik-dimension").width())
                bottom: "520px"
                chapter: false
                title: "Was singen die Chorknaben?"
                caption: "Eine grobe &Uuml;bersicht unseres Repertoires."
                revertHash: "#!/musik"
                content: "<p>Prosciutto sirloin filet mignon pancetta. Rump frankfurter tail, fatback cow tenderloin ham hock. Strip steak meatball beef shank doner jowl turducken bacon t-bone biltong salami. Prosciutto meatball pancetta filet mignon brisket ham jowl sirloin. Biltong ground round brisket, sirloin tail corned beef pig pork chop ball tip shoulder beef ribs frankfurter beef pork salami.</p><ul class=\"musik-werke\"><li>Dieses Werk</li><li>Dieses Werk</li><li>Dieses Werk</li><li>Dieses Werk</li><li>Dieses Werk</li></ul>"



window.core.insertChildPage(new Musik())

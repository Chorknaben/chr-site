class Unterstutzen extends ChildPage
    constructor: ->
        super()

    onLoad: ->
    	window.core.setMetaDesc("M&ouml;glichkeiten der Unterst&ouml;tzung", "Unterst&uuml;tzen")

    onUnloadChild: ->
    	window.core.revMetaDesc()

window.core.insertChildPage(new Unterstutzen())

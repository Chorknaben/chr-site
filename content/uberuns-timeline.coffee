class UberunsTimeline extends ChildPage
    constructor: ->
        @core = window.core

    onLoad: ->
    	@core.setMetaDesc("Chorgeschichte", "Chorgeschichte")

    onUnloadChild: ->
    	@core.revMetaDesc()

    notifyHashChange: (newHash) ->

window.core.insertChildPage(new UberunsTimeline())

class UberunsTimeline extends ChildPage
    constructor: ->
        @core = window.core

    onLoad: ->

    onUnloadChild: ->

    notifyHashChange: (newHash) ->

window.core.insertChildPage(new UberunsTimeline())

class UberunsTimeline extends ChildPage
    onLoad: ->

    onUnloadChild: ->

    notifyHashChange: (newHash) ->

window.core.insertChildPage(new UberunsTimeline())

class UberunsTeam extends ChildPage
    constructor: ->
        @core = window.core

    onLoad: ->

    onUnloadChild: ->

    notifyHashChange: (newHash) ->

window.core.insertChildPage(new UberunsTeam())

class Presse extends ChildPage
    @ready = false
    @wall  = null
    constructor: ->
        super()

    acquireLoadingLock: ->
        return true

    notifyHashChange: (hash) ->
        console.log hash

    onLoad: ->
        window.core.release()

    onScrollFinished: ->

    onUnloadChild: ->


window.core.insertChildPage(new Presse())

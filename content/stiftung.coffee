class Stiftung extends ChildPage
    constructor: ->
        super()

    onLoad: ->
    onUnloadChild: ->

    notifyHashChange: (newHash) ->
        if newHash is "/" or newHash is ""
            # User has clicked the "Stiftung" Button
            $(".stiftung-main-area").eq(1).addClass("nodisplay")
            $(".stiftung-main-area").eq(0).removeClass("nodisplay")

        if newHash is "/forderverein"
            $(".stiftung-main-area").eq(0).addClass("nodisplay")
            $(".stiftung-main-area").eq(1).removeClass("nodisplay")


window.core.insertChildPage(new Stiftung())

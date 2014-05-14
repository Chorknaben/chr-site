class UberunsTeam extends ChildPage
    constructor: ->
        super()
        # Map the respective persons to a fixed ID.
        # Why not just use a onclick-event, you ask?
        # Using an onclick-event has the disadvantage of, well,
        # a click having to occur. The user will not be able to
        # share this link somewhere with the Tile already "opened".
        @linkIDMapper = [
            ["johannes", 0]
          , ["lechner", 1]
          , ["noah", 2]
          , ["samuel", 3]
          , ["dschingis", 4]]

        @clickedPreviously = null

    onLoad: ->

    onUnloadChild: ->

    notifyHashChange: (newHash) ->
        for el in @linkIDMapper
            if "/#{el[0]}" is newHash
                @reset(true)
                @handle(el[1])
                @clickedPreviously = el[1]
                return

        if newHash is "/" or newHash is ""
            @reset()

    handle: (id) ->
        $(".reise-tile").eq(id)
            .children(".before-transition")
            .addClass("invisible")

        $(".reise-tile").eq(id)
            .children(".after-transition")
            .css display: "initial"

    reset: (force = false) ->
        if not force
            $(".reise-tile").eq(@clickedPreviously).children(".before-transition")
                .removeClass("invisible")

            $(".reise-tile").eq(@clickedPreviously).children(".after-transition")
                .css display: "none"
        else
            $(".reise-tile").eq(@clickedPreviously)
                .children(".before-transition")
                .removeClass("invisible")

            #setTimeout( => 
                $(".reise-tile").eq(@clickedPreviously)
                    .children(".after-transition")
                    .css display: "none"
            #, 200)

window.core.insertChildPage(new UberunsTeam())

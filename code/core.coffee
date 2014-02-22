class Constants
    @SELECTOR_TILE = ".tile-content"
    @SELECTOR_NAV  = ".navitem nav"

class Core
    bgSrc : "/#{ $(window).width() }/#{ $(window).height() - 90 }/"

    debug = (msg) -> console.log "Core: " + msg
        
    construct: ->
    handleHash: ->
        # If the site gets called and a hash is already set, for example when the
        # user has bookmarked a page and is now clicking on the bookmarked link,
        # trigger the corresponding tile onclick event
        if window.location.hash isnt ""
            debug "Hash detected"
            for i in [0..7]
                debug i
                if "#" + tileResolver[i][1] is window.location.hash
                    tileOnClickHandler(i+1)()
                    break

    injectBackground: ->
        # Determine the resolution of the client and send it to the server.
        # The server will return a matching background image.
        debug @bgSrc
        $ "<img>", src: @bgSrc + "bg"
            .appendTo($ "#bg").load ->
                #$(@).show()
                $(@).fadeIn 300
                #$("#bg").css("background-image": "url(#{@bgSrc}bg)")
                #       .fadeIn 300

    injectTileBackgrounds: ->
        # inject Tile Backgrounds as background attributes to the corresponding DOM
        # Elements.
        for i in [12..0]
            $("#" + i).css "background-image" : "url(#{@bgSrc + i})"
            $("#" + i).click (tileOnClickHandler i)

    loadEffects: ->
        stl = $( Constants.SELECTOR_TILE )

        stl.each (index, obj) ->
            obj = $ ( obj )
            obj.hover ->
                obj.children "a"
                   .children ".hoveroverlay"
                   .animate opacity:"0.7", 100
                $ stl.not(".hoveroverlay")[ index - 1 ]
                    .children ".hoveroverlay"
                    .animate opacity:"0", 100
            , ->
                obj.children "a"
                   .children ".hoveroverlay"
                   .animate opacity:"0", 100
                $ stl[ index - 1 ]
                    .children "a"
                    .children ".hoveroverlay"
                    .animate opacity:"0", 100




$ ->
    c = new Core
    c.handleHash()
    c.injectBackground()
    c.injectTileBackgrounds()
    c.loadEffects()


class Stiftung extends ChildPage
    constructor: ->
        super()

        @buttonStiftung = $("#btn-stiftung")
        @buttonForderverein = $("#btn-forderverein")

        @contents = [
            $("#ziele-und-zweck"),
            $("#missa-1962"),
            $("#zustiften"),
            $("#kontaktieren")
        ]

        @contentsf = [
            $("#fziele"),
            $("#mitgliedsein"),
            $("#spenden"),
            $("#fkontaktieren")
        ]

        @nav = $(".stiftung-subnav").children()


    onLoad: ->
        window.core.setMetaDesc("Die Stiftung St.-Martins-Chorknaben Biberach wurde im April 2010 gegr&uuml;ndet und hat das Ziel, die Finanzierung von Chorleitung und Stimmbildung nachhaltig zu sichern.", "Stiftung")

    nodisplay: ->
        for i in @contents
            i.addClass("nodisplay")

    fnodisplay: ->
        for i in @contentsf
            i.addClass("nodisplay")

    setAreaCol: (col) ->
        stiftungMainArea = $("#cnt-stiftung")
        stiftungMainArea.removeClass().addClass("stiftung-main-area")
        stiftungMainArea.addClass(col)

    fSetAreaCol: (col) ->
        fordervereinMainArea = $("#cnt-forderverein")
        fordervereinMainArea.removeClass().addClass("stiftung-main-area")
        fordervereinMainArea.addClass(col)

    onUnloadChild: ->
        window.core.revMetaDesc()

    notifyHashChange: (newHash) ->
        if newHash is "/" or newHash is ""
            @buttonStiftung.addClass("active")
            @buttonForderverein.removeClass("activef")

            # User has clicked the "Stiftung" Button
            $(".stiftung-main-area").eq(1).addClass("nodisplay")
            $(".stiftung-main-area").eq(0).removeClass("nodisplay")

        if newHash is "/ziele"
            @nodisplay()
            @setAreaCol("li-1")
            @contents[0].removeClass("nodisplay")

        if newHash is "/missa"
            @nodisplay()
            @setAreaCol("li-2")
            @contents[1].removeClass("nodisplay")

        if newHash is "/zustiften"
            @nodisplay()
            @setAreaCol("li-3")
            @contents[2].removeClass("nodisplay")

        if newHash is "/kontaktieren"
            @nodisplay()
            @setAreaCol("li-4")
            @contents[3].removeClass("nodisplay")

        if newHash.indexOf("/forderverein") is 0
            @buttonStiftung.removeClass("active")
            @buttonForderverein.addClass("activef")

            $("#cnt-stiftung").addClass("nodisplay")
            $("#cnt-forderverein").removeClass("nodisplay")
            
            @fnodisplay()
            @fSetAreaCol("fi-1")
            @contentsf[0].removeClass("nodisplay")

        if newHash is "/forderverein/ziele"
            @fnodisplay()
            @fSetAreaCol("fi-1")
            @contentsf[0].removeClass("nodisplay")

        if newHash is "/forderverein/mitglied-sein"
            @fnodisplay()
            @fSetAreaCol("fi-2")
            @contentsf[1].removeClass("nodisplay")

        if newHash is "/forderverein/spenden"
            @fnodisplay()
            @fSetAreaCol("fi-3")
            @contentsf[2].removeClass("nodisplay")

        if newHash is "/forderverein/kontaktieren"
            @fnodisplay()
            @fSetAreaCol("fi-4")
            @contentsf[3].removeClass("nodisplay")

window.core.insertChildPage(new Stiftung())

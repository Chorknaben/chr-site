$ ->
    $('.image-thumb').each (i) ->
        $(this).css({'background-image':'url(/images/thumbs/' + (i + 1) + ')'})

    window.core.registerScrollHandler "pullup", ->
      $(".pullup-element").each (i, el) ->
        el = $(el)
        if (el.visible(true))
          el.addClass("come-in")

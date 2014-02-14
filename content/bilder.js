$(document).ready(function(){
    console.log("bilder.js firing document.ready");
    $('.image-thumb').each(function(i){
        $(this).css({'background-image':'url(/images/thumbs/' + (i + 1) + ')'});
    });
});


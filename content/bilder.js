$(document).ready(function(){
    $('.image-thumb').each(function(i){
        //$(Obj).css({background-image:'/images/thumbs/'+i});
        //$(Obj).css({background-image:'/images/thumbs/'+i});
        console.log(this);
        $(this).css({'background-image':'url(/images/thumbs/'+(i+1)+')'});
    })
});


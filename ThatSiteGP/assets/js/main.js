jQuery(document).ready(function($) {
$(window).scroll(function() {
            var vr = $(this).scrollTop();
            $('.menu').css({'transform':'translate(0%,'+ vr +'%)'}); 
});

    /*======= Skillset *=======*/
    
    
    $('.level-bar-inner').css('width', '0');
    
    $(window).on('load', function() {

        $('.level-bar-inner').each(function() {
        
            var itemWidth = $(this).data('level');
            
            $(this).animate({
                width: itemWidth
            }, 800);
            
        });

    });
   
    

});
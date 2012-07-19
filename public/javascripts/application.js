// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function (){  
 
/*
    jQuery.ajaxSetup({  
         'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
    });    
*/    
    jQuery.fn.submitWithAjax = function () {  
        this.submit(function () {  
            $.post($(this).attr('action'), $(this).serialize(), null, "script");  
            return false;  
          });  
        }; 

     jQuery.fn.submitWithAjax = function () {  
        this.submit(function () {  
            $.post($(this).attr('action'), $(this).serialize(), null, "script");  
            return false;  
          });  
        }; 

    // MODALS: Home-made ajax + close modal ToDo: fix url, should be passed as parameter

    jQuery.fn.act_as_modal = function () {  

        $(this).unbind();
        $(this).click(function() { 
            url = $(this).attr('data-href')
            if (('#rules_form').length) {url += '?' + $('#rules_form').serialize()}
            $.ajax(url);
            $('#modalcontainer > div').hide(); // not clear why this isn't working when either of the button clicked
            $('#overlay').hide();
        })  
        
    }
    
    // ALERTS
    $(".alert").alert()
    
    // For sroa this binding doesn't work out of the alert box
    $('[data-dismiss="alert"]').bind('click', function () {
        $(this).alert('close');
    })
    

    // PJAX
    
    $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]')
   
    $('nav#secondary a').pjax('[data-pjax-container]');

/* REPLACE WITH DATA-SKIP-PJAX THERE
    $('nav#primary a').click(function() {
        window.location = $(this).attr("href");
        return false;
    });
     
/*
    $('#dashboard_right').bind('start.pjax', function() {
        $('#dashboard_right').fadeOut(1000) 
        }).bind('end.pjax', function() { 
        $('#dashboard_right').fadeIn(1000) 
    });
*/         
});
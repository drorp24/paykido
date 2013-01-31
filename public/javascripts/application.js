// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function (){  
 
/*
    jQuery.ajaxSetup({  
         'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
    });    
*/    

    $('[rel="popover"]').popover({placement: "left"});

    $('[title]').not('[rel="popover"]').tooltip();

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

    jQuery.fn.post_as_modal = function () {     // NOT USED. DELETE THIS AND EVENTUALLY ACT_AS_MODAL TOO

        $(this).unbind();
        $(this).click(function() { 
            url = $(this).attr('data-href')
            $.post(url);
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
    
//    $.pjax.defaults.timeout = 5000

    $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]')
        
//    $('#dashboard_right').bind('start.pjax', function() { $('#dashboard_right').fadeOut(500) }).bind('end.pjax', function() { $('#PJAXcontainer').fadeIn(500) });
//    $('#dashboard_right').bind('pjax:start', function() { $('#dashboard_right').fadeOut(500) }).bind('pjax:end', function() { $('#PJAXcontainer').fadeIn(500) });
   

    $(document)
        .on('pjax:end', function() { 
            $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]')
            sp_init();
        })
        .on('end.pjax', function() { 
            $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]')
            sp_init();
        })

    
/*
    $('#dashboard_right').bind('start.pjax', function() {
        $('#dashboard_right').fadeOut(1000) 
        }).bind('end.pjax', function() { 
        $('#dashboard_right').fadeIn(1000) 
    });
*/  

/////// COPY FROM SPINA APPLICATION.JS //////

  function sp_init() {
    
  
    /*************
      Datatables
    *************/
  
    $('.datatable').dataTable({
      "sPaginationType": "full_numbers",
      "bStateSave": true
    });
  
    $('.dataTables_wrapper').each(function() {
      var table = $(this);
      var info = table.find('.dataTables_info');
      var paginate = table.find('.dataTables_paginate');
    
      table.find('.datatable').after('<div class="action_bar nomargin"></div>');
      table.find('.action_bar').prepend(info).append(paginate);
    });
    
    /**********************
      Modal functionality
    **********************/
  
    $('a.sp_modal').each(function() {
      var link = $(this);
      var id = link.attr('href');
      var target = $(id);
      
      if($("#modalcontainer " + id).length == 0) {
        $("#modalcontainer").append(target);
      }
      
      $("#main " + id).remove();
    
      link.click(function() {
        $('#modalcontainer > div').hide();
        target.show();
        $('#overlay').show();
      
        return false;
      });
    });
  
    $('.close').click(function() {
      $('#modalcontainer > div').hide();
      $('#overlay').hide();
    
      return false;
    });
    
    /***********************
      Secondary navigation
    ***********************/
    
    $('nav#secondary > ul > li > a').click(function() {
      $('nav#secondary li').removeClass('active');
      $(this).parent().addClass('active');
    });
  
  
    
    // Calendar icon fix
    $('form p > .error').livequery(function() {
      $(this).siblings('span.calendar').hide();
    });
  
    // Add valid icons to validatable fields
    $('form p > *').each(function() {
      var element = $(this);
      if(element.metadata().validate) {
        element.parent().append('<span class="icon tick valid"></span>');
      }
    });
  }
  
  sp_init();

});

/*************************
  Notification function!
*************************/

function notification(message, error, icon, image) {
  if(icon == null) {
    icon = 'tick2';
  }
  
  if(image) {
    image = 'icon16';
  } else {
    image = 'glyph';
  }
  
  var now = new Date();
  var hours = now.getHours();
  var minutes = now.getMinutes();
    
  if (hours < 10) {
    hours = "0" + hours;
  }
  
  if (minutes < 10) {
    minutes = "0" + minutes;
  }
  
  var time = hours + ':' + minutes;
  
  if(error) {
    $('#notifications ul').append('<li class="error"><span class="' + image + ' cross"></span> ' + message + ' <span class="time">' + time + '</span></li>');
  } else {
    $('#notifications ul').append('<li><i class="' + icon + '"></i> ' + message + ' <span class="time">' + time + '</span></li>');
  }
  
  $('#notifications ul li:last-child').hide();
  $('#notifications ul li:last-child').slideDown(200);

}

///////  COPY FROM SPINA APPLICATION.JS /////       

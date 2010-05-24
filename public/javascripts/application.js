// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({  
     'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});

$(document).ready(function (){  
		 
	$('#new_retailer').submit(function (){  
   		$.post($(this).attr('action'), $(this).serialize(), null, "script");  
    	return false;  
   });  
		 
	$(function(){
	//all hover and click logic for buttons
		$(".fg-button:not(.ui-state-disabled)")
			.hover(
				function(){ 
					$(this).addClass("ui-state-hover"); 
				},
				function(){ 
					$(this).removeClass("ui-state-hover"); 
				}
			 )
			.mousedown(function(){
					$(this).parents('.fg-buttonset-single:first').find(".fg-button.ui-state-active").removeClass("ui-state-active");
						if( $(this).is('.ui-state-active.fg-button-toggleable, .fg-buttonset-multi .ui-state-active') ){ $(this).removeClass("ui-state-active"); }
						else { $(this).addClass("ui-state-active"); }	
			 })
			.mouseup(function(){
						if(! $(this).is('.fg-button-toggleable, .fg-buttonset-single .fg-button,  .fg-buttonset-multi .fg-button') ){
							$(this).removeClass("ui-state-active");
						}
			});
		});
		$(function() {
			$("#tabs").tabs({
				ajaxOptions: {
					error: function(xhr, status, index, anchor) {
					$(anchor.hash).html("Couldn't load this tab. We'll try to fix this as soon as possible. If this wouldn't be a demo.");
				}
			}
		});
		});
});
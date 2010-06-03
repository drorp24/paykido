// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({  
     'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});

jQuery(document).ready(function (){  
		 
/*
	$('#new_payer').submit(function (){  
   		$.post($(this).attr('action'), $(this).serialize(), null, "script");  
    	return false;  
   });  

*/		 
	jQuery(function(){
	//all hover and click logic for buttons
		jQuery(".fg-button:not(.ui-state-disabled)")
			.hover(
				function(){ 
					jQuery(this).addClass("ui-state-hover"); 
				},
				function(){ 
					jQuery(this).removeClass("ui-state-hover"); 
				}
			 )
			.mousedown(function(){
					jQuery(this).parents('.fg-buttonset-single:first').find(".fg-button.ui-state-active").removeClass("ui-state-active");
						if( jQuery(this).is('.ui-state-active.fg-button-toggleable, .fg-buttonset-multi .ui-state-active') ){ $(this).removeClass("ui-state-active"); }
						else { jQuery(this).addClass("ui-state-active"); }	
			 })
			.mouseup(function(){
						if(! jQuery(this).is('.fg-button-toggleable, .fg-buttonset-single .fg-button,  .fg-buttonset-multi .fg-button') ){
							jQuery(this).removeClass("ui-state-active");
						}
			});
		});
		jQuery(function() {
			jQuery("#tabs").tabs().find(".ui-tabs-nav").sortable({axis:'x'});
	});

});
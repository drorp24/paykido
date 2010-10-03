// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({  
     'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});


jQuery.fn.submitWithAjax = function () {  
	this.submit(function () {  
		$.post($(this).attr('action'), $(this).serialize(), null, "script");  
	    return false;  
	  });  
	}; 
	
$(document).ready(function (){  
		 
	$('#phone_form').submitWithAjax(); 
	$('#pin_form').submitWithAjax();
	$('#allowance_form').submitWithAjax();
	$('#amounts_form').submitWithAjax();
	$('#phone_alert_form').submitWithAjax();
	$('#email_alert_form').submitWithAjax();
	$('#consumer_form').submitWithAjax();
	$('#consumer_info_form').submitWithAjax();
	$('#community_form').submitWithAjax();
	$('#other_form').submitWithAjax();
	


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
			$("#tabs, #consumers_tabs, #preferences_tabs").tabs().find(".ui-tabs-nav").sortable({axis:'x'});
			$("#consumers_tabs").tabs("select", 0);
		});
	
		$(function() {
			$("#selectable").selectable();
		});
		

		$(function() {
			$("#check").button();
		});


		$(function() {
			$(".buttonset").buttonset();
		});
		
		$("#tabs").tabs({
			select: function(event, ui){
				if (ui.index != 4) {
				$('#payer-in-tab').html($('#payer_name').val());
				$('.pic-in-tab').attr('style', 'display: none;');
				viewPurchases("all");}
			}
		});
		

});
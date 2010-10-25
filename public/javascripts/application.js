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
			$("#payer_tabs, #retailer_tabs, #consumers_tabs, #preferences_tabs").tabs().find(".ui-tabs-nav").sortable({axis:'x'});
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
		

	$("#payer_tabs").tabs({
				select: function(event, ui){
				if (ui.index != 5) {
				$('#payer-in-tab').html($('#payer_name').val().substring(0,14));
				$('.pic-in-tab').attr('style', 'display: none;');
				viewPurchases("all");}
			}
		});

	$(".portlet").draggable({
			cursor: "move",
			cursorAt: { top: 10, left: 10 },
			helper: function( event ) {
				if ($(this).find('img').length) {
					return $( $(this).find('.portlet-content-left').html());
				}
				else {
					return $( $(this).find('.portlet-name').html());
				}
			}
	});
			
	$("#purchases_tab").droppable({
			
			tolerance: 'touch',

			hoverClass: "ui-state-active",

			over: function( event, ui ) {
				if (ui.draggable.find('input').length) {
				    $('#payer-in-tab').html(ui.draggable.find('input').val() + "'s");
					$('.pic-in-tab').removeClass('logo-in-tab');
				}
				else { 
				    $('#payer-in-tab').html(ui.draggable.find('.portlet-header').contents().filter(function() {return this.nodeType == 3}).text());
					$('.pic-in-tab').addClass('logo-in-tab');
				}
				$('.pic-in-tab').attr('style', 'display: inline;');
				if (ui.draggable.find('img').length) {
				    $('.pic-in-tab').attr('src', ui.draggable.find('img').attr('src'));
				}
				else {
				    $('.pic-in-tab').attr('style', 'display: none');
				}
			},
			
			out: function( event, ui ) {
				$('#payer-in-tab').html($('#payer_name').val().substring(0,14));
				$('.pic-in-tab').attr('style', 'display: none;');				
			},

			drop: function( event, ui ) {
				if (ui.draggable.find('input').length) {
				    $('#payer-in-tab').html(ui.draggable.find('input').val() + "'s");
					$('.pic-in-tab').removeClass('logo-in-tab');
				}
				else { 
				    $('#payer-in-tab').html(ui.draggable.find('.portlet-header').contents().filter(function() {return this.nodeType == 3}).text());
					$('.pic-in-tab').addClass('logo-in-tab');
				}
				$('.pic-in-tab').attr('style', 'display: inline;');
				if (ui.draggable.find('img').length) {
				    $('.pic-in-tab').attr('src', ui.draggable.find('img').attr('src'));
				}
				else {
				    $('.pic-in-tab').attr('style', 'display: none');
				}
				$("#payer_tabs").tabs("select", 5);
				viewPurchases(ui.draggable.find('.portlet-header').attr("id"));
			}
	});
	


});
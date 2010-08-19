

	$('#cheerful_message').fadeOut(1200);
	
	
			$('#consumer_form .column2').prepend(
				'<div class="portlet ui-widget ui-widget-content ui-helper-clearfix ui-corner-all">'+
					'<div class="consumer portlet-header ui-widget-header ui-corner-all" id="consumer_281">'+
						'<input id="consumer_281_name" name="consumer[281][name]" onchange="rename_consumer(281, $(this).val())" size="30" type="text" />'+
					'</div>'+
					'<div class="portlet-content" >'+
						'<div class="portlet-content-left">'+
							'<img alt="Face_placeholder_small" class="face-placeholder" src="/images/face_placeholder_small.png?1276810372" />'+
						'</div>'+
						'<div class="portlet-content-right">'+
							'<p class="consumer-info">Spent nothing this month</p>'+
							'<p class="consumer-info">Monthly balance:&nbsp  $200.00</p>'+		
						'</div>'+
					'</div>'+
				'</div>');	
	
	
	consumer_info(281);
	setTabHeight(4, 0);
	

	
$(function() {
	$('#consumer_form .column1').sortable({
		connectWith: '#consumer_form .column2'
	});
	$('#consumer_form .column2').sortable({
		connectWith: '#consumer_form .column1'
	});
	
	$(".portlet").addClass("ui-widget ui-widget-content ui-helper-clearfix ui-corner-all")
		.find(".consumer.portlet-header")
			.addClass("ui-widget-header ui-corner-all")
			.prepend('<span class="ui-icon ui-icon-minusthick"></span>')
			.end()
		.find(".consumer.portlet-content");

	$(".portlet-header .ui-icon").click(function() {
		$(this).toggleClass("ui-icon-minusthick").toggleClass("ui-icon-plusthick");
		$(this).parents(".portlet:first").find(".portlet-content").toggle();
	});
	
	$("#consumer_form .column1").disableSelection();
});

	$('.consumer.portlet-header').click(function () { 
		
		consumer_info($(this).attr('id').split('_')[1]);
		
	 });
	 
	$("input[value='']").val("(name here)");	

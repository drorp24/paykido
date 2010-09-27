

	$('.categories_list').append(	
		'<p class="inner_content_title">&nbsp;</p>' +
		'<p class="content-name-right" id="consumers">Your purchases fall in the following categories</p>'+		
		'<div class="column1" ></div>' +
		'<div class="column2" ></div>');
			
	

	
		
		
			$('.categories_list .column1').append(
				'<div class="portlet">'+
					'<div class="category portlet-header" id="category_6">Virtual Cash</div>'+
					'<div class="portlet-content" style="padding-bottom:0" >'+
						'<div class="portlet-content-left">'+
							'<p class=content-name>Virtual Cash</p>'+
							'<p class="category-info">Total monthly purchases:&nbsp;$9.00</p>'+
						'</div>'+
						'<div class="portlet-content-right">'+
						'</div>'+
					'</div>'+
				'</div>');
		
		
	

	category_info(6);

	




	function category_info(id) {
		var selector = "div[id = category_" + id.toString() + " ]"
			
		$('.category.portlet-header').removeClass('ui-widget-header-lightness');
		$(selector).addClass('ui-widget-header-lightness');
		$.ajax({
			url: 'category/'+id,
			success: function(data){
			}
		})
	};



$(function() {
	$('.categories_list .column1').sortable({
		connectWith: '.categories_list .column2'
	});
	$('.categories_list .column2').sortable({
		connectWith: '.categories_list .column1'
	});
	
	$(".portlet").addClass("ui-widget ui-widget-content ui-helper-clearfix ui-corner-all")
		.find(".category.portlet-header")
			.addClass("ui-widget-header ui-corner-all")
			.prepend('<span class="ui-icon ui-icon-minusthick"></span>')
			.end()
		.find(".category.portlet-content");

	$(".portlet-header .ui-icon").click(function() {
		$(this).toggleClass("ui-icon-minusthick").toggleClass("ui-icon-plusthick");
		$(this).parents(".portlet:first").find(".portlet-content").toggle();
	});
	
	$(".categories_list .column1").disableSelection();
});

	$('.category.portlet-header').click(function () { 
		
		category_info($(this).attr('id').split('_')[1]);
		
	 }); 
// Tabs

$(document).ready(function() {

	//When page loads...
	$(".tab_content").hide(); //Hide all content
	$("ul.tabs li:first").addClass("current").append("<span class='left'></span><span class='right'></span>").show(); //Activate first tab
	$(".tab_content:first").show(); //Show first tab content

	//On Click Event
	$("ul.tabs li").click(function() {

		$("ul.tabs li").removeClass("current"); //Remove any "current" class
		$("ul.tabs li span").removeClass("left").removeClass("right"); //Remove any "current" class
		$(this).addClass("current").append("<span class='left'></span><span class='right'></span>"); //Add "current" class to selected tab
		$(".tab_content").hide(); //Hide all tab content

		var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
		$(activeTab).fadeIn(); //Fade in the active ID content
		return false;
	});

});

<link rel="stylesheet" media="screen" href="css/notifications.css" />
<script type="text/javascript" src="js/jquery.ui.widget.min.js"></script>
<script type="text/javascript" src="js/jquery.notify.js"></script>

<script type="text/javascript">	
	$(function(){
        var $container;
        
        function create( template, vars, opts ){
            return $container.notify("create", template, vars, opts);
        }

        // initialize widget on a container, passing in all the defaults.
		// the defaults will apply to any notification created within this
		// container, but can be overwritten on notification-by-notification
		// basis.
		$container = $("#container").notify();
		
		// create two when the page loads
		//create("default-container", { title:'Default Notification', text:'Example of a default notification.  I will fade out after 5 seconds'});
		//create("sticky-container", { title:'Sticky Notification', text:'Example of a "sticky" notification.  Click on the X above to close me.'},{ expires:false });
		
		// bindings for the examples
		$("#default").click(function(){
			create("default-container", { title:'Default Notification', text:'This is a basic growl notification.  I will fade out after 5 seconds'});
		});

		$("#header").click(function(){
			create("header-container", { title:'Growl without Header', text:'Growl message without header.'},{ expires:false });
		});
		
		$("#sticky").click(function(){
			create("sticky-container", { title:'Sticky Notification', text:'Example of a "sticky" growl.  Click on the X above to close me.'},{ expires:false });
		});
		
		$("#buttons").click(function(){
			var n = create("buttons-container", { title:'Confirm some action', text:'This template has a button.' },{ 
				expires:false
			});
			
			n.widget().delegate("input","click", function(){
				n.close();
			});
		});
		
		$("#clickable").click(function(){
			create("default-container", { title:'Clickable Notification', text:'Click anywhere on me to fire a callback. Do it quick though because I will fade out after 5 seconds.'}, {
				click: function(e,instance){
					alert("Click triggered!\n\nTwo options are passed into the click callback: the original event obj and the instance object.");
				}
			});
		});

		//growl messages
		$("#info-growl").click(function(){
			create("info-container", { title:'Information', text:'The UI is presenting useful information.', icon:'images/navicons/171.png' },{ 
				expires:false
			});
		});

		$("#success-growl").click(function(){
			create("success-container", { title:'Success!', text:'The UI is presenting a complete and successful operation.', icon:'images/navicons/92.png' },{ 
				expires:false
			});
		});
		
		$("#warning-growl").click(function(){
			create("warning-container", { title:'Warning!', text:'The UI is presenting a condition that might cause a problem in the future.', icon:'images/navicons/163.png' },{ 
				expires:false
			});
		});
		
		$("#error-growl").click(function(){
			create("error-container", { title:'Error!', text:'The user interface (UI) is presenting an error or problem that has occurred.', icon:'images/navicons/172.png' },{ 
				expires:false
			});
		});
	});
</script>

<h1 class="page-title">Notifications</h1>
<div class="container_12 clearfix leading">
	<section class="portlet grid_6">
		<header>
			<h2>Notifications</h2> 
        </header>
        <section>
        	<div class="message info"> 
                <h3>Information</h3> 
                <p> 
                    This is an info message.
                </p> 
            </div> 
            <div class="message success"> 
                <h3>Success!</h3> 
                <p> 
                    This is a success message.
                </p> 
            </div> 
            <div class="message warning"> 
                <h3>Warning!</h3> 
                <p> 
                    This is a warning message.
                </p> 
            </div> 
            <div class="message error"> 
                <h3>Error!</h3> 
                <p> 
                    This is an error message.
                </p> 
            </div>
        </section>
    </section>
    
    <section class="portlet grid_6">
		<header>
			<h2>Closeable Notifications</h2> 
        </header>
        <section>
        	<div class="message info closeable">
				<h3>Information</h3>
				<p> This is a closeable info message. </p>
			</div>
			<div class="message success closeable">
				<h3>Success!</h3>
				<p> This is a closeable success message. </p>
			</div>
			<div class="message warning closeable">
				<h3>Warning!</h3>
				<p> This is a closeable warning message. </p>
			</div>
			<div class="message error closeable">
				<h3>Error!</h3>
				<p> This is a closeable error message. </p>
			</div>
        </section>
    </section>

    <div class="clear"></div>
    
	<section class="portlet grid_12 leading">
		<header>
			<h2>Growl notifications</h2> 
        </header>
        <section class="clearfix">
            <div class="grid_6 alpha">
            	<p><input type="button" id="default" value="Default growl"/></p>
				<p><input type="button" id="sticky" value="Sticky growl"/></p>
				<p><input type="button" id="buttons" value="Growl with button"/></p>
				<p><input type="button" id="header" value="Growl without header"/></p>
				<p><input type="button" id="clickable" value="Entire message can be click"/></p>
            </div>
            <div class="grid_6 omega">
            	<p><input type="button" id="info-growl" value="Information Growl"/></p>
	        	<p><input type="button" id="success-growl" value="Success Growl"/></p>
	        	<p><input type="button" id="warning-growl" value="Warning Growl"/></p>
	        	<p><input type="button" id="error-growl" value="Error Growl"/></p>
            </div>
        </section>
	</section>
	
	<!--  container to hold growl notifications, and default templates -->
	<div id="container" style="display: none;">
		
		<div id="default-container">
			<h1>#{title}</h1>
			<p>#{text}</p>
		</div>
		
		<div id="header-container">
			<a class="ui-notify-close ui-notify-cross" href="#">x</a>
			<p>#{text}</p>
		</div>
		
		<div id="sticky-container">
			<a class="ui-notify-close ui-notify-cross" href="#">x</a>
			<h1>#{title}</h1>
			<p>#{text}</p>
		</div>

		<div id="buttons-container">
			<h1>#{title}</h1>
			<p>#{text}</p>
			<p style="margin-top:10px;text-align:center">
				<input type="button" class="confirm" value="Close Dialog"/>
			</p>
		</div>
		
		<div id="info-container">
			<a class="ui-notify-close ui-notify-cross" href="#">x</a>
			<div class="with-icon"><img src="#{icon}" alt="info"/></div>
			<h1>#{title}</h1>
			<p>#{text}</p>
		</div>
		
		<div id="success-container">
			<a class="ui-notify-close ui-notify-cross" href="#">x</a>
			<div class="with-icon"><img src="#{icon}" alt="success"/></div>
			<h1>#{title}</h1>
			<p>#{text}</p>
		</div>
		
		<div id="warning-container">
			<a class="ui-notify-close ui-notify-cross" href="#">x</a>
			<div class="with-icon"><img src="#{icon}" alt="warning"/></div>
			<h1>#{title}</h1>
			<p>#{text}</p>
		</div>
		
		<div id="error-container">
			<a class="ui-notify-close ui-notify-cross" href="#">x</a>
			<div class="with-icon"><img src="#{icon}" alt="error"/></div>
			<h1>#{title}</h1>
			<p>#{text}</p>
		</div>
		
	</div>
</div>

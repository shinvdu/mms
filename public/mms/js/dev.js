$(document).ready(function(){
    $('#header').load('header.html', function() {
	$('#user-name').on('click', function(e) {
	    $('#user-menu').toggle();
	    e.preventDefault();
	});

/*
	$('#user-name').on('blur', function(e) {
	    $('#user-menu').hide();
	    e.preventDefault();
	});
*/
    });
    $('#footer').load('footer.html');
});

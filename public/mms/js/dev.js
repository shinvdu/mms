$(document).ready(function(){
    $('#header').load('header.html', function() {
	$('#user-name').on('click', function(e) {
	    $('#user-menu').toggle();
	    e.preventDefault();
	});
    });
    $('#navbar').load('navbar.html', function() {
	$(this).find('a[href="' + document.location.pathname.match(/\/([\w=]+\.html)/)[1] + '"]').parent().addClass('active');
    });
    $('#footer').load('footer.html');
});

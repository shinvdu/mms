$(document).ready(function(){
    $('#header').load('header.html', function() {
	$('#user-name').on('click', function(e) {
	    $('#user-menu').toggle();
	    e.preventDefault();
	});
    });
    $('#navbar').load('navbar.html', function() {
	$(this).find('a[href="' + document.location.pathname.match(/\/([\w=]+\.html)/)[1] + '"]').parent().addClass('active');
	$('.navbar-link').on('click', function(e) {
	    $('.nav-tab > .nav-square > li').removeClass('current');
	    $('.nav-tab > .nav-square > li').find('a[href="' + $(this).attr('href').match(/#[\w-]+/)[0] + '"]').parent().addClass('current');
	    $('.tab-panel').removeClass('current');
	    $($(this).attr('href').match(/#[\w-]+/)[0]).addClass('current');
	});
    });
    $('#footer').load('footer.html');
});

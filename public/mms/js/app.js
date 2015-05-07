'use strict'

var main = function() {
    $('.nav-tab > .nav-square a').on('click', function(e) {
	var panelID = $(this).attr('href'),
	    currentTab = $(this).parent();
	$('.tab-panel').removeClass('current');
	$(panelID).addClass('current');
	$('.nav-tab > .nav-square > li').removeClass('current');
	currentTab.addClass('current');
	e.preventDefault();
    });

    $('#btn-add-advertisement').on('click', function(e) {
	$('.tab-panel').removeClass('current');
	$('#add-advertisement').addClass('current');
	e.preventDefault();
    });

    $('#btn-add-permission-control').on('click', function(e) {
	$('.tab-panel').removeClass('current');
	$('#add-permission-control').addClass('current');
	e.preventDefault();
    });

    $('#btn-add-user').on('click', function(e) {
	$('.tab-panel').removeClass('current');
	$('#add-user').addClass('current');
	e.preventDefault();
    });

    $('#btn-add-transcoding-template').on('click', function(e) {
	$('.tab-panel').removeClass('current');
	$('#add-transcoding-template').addClass('current');
	e.preventDefault();
    });

    $('#btn-add-transcoding-solution').on('click', function(e) {
	$('.tab-panel').removeClass('current');
	$('#add-transcoding-solution').addClass('current');
	e.preventDefault();
    });

    $('.btn-return-link').on('click', function(e) {
	var returnID = $(this).attr('href');
	$('.tab-panel').removeClass('current');
	$(returnID).addClass('current');
	e.preventDefault();
    });	

    $('#btn-add-new-player').on('click', function(e) {
	$('.tab-panel').removeClass('current');
	$('#add-new-player').addClass('current');
	e.preventDefault();
    });

};

$(document).ready(main);

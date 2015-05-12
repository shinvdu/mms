'use strict'
function element_lists() {
	var container = []
	$('#video_select_list').children().each(function(){
		var p = $(this)
		var start  = p.attr('data-start');
		var end  = p.attr('data-end');
		container.push({start: start, end: end})
	})
	return container;
}

var main = function() {
    var currentPanel = document.location.hash,
	options = {
	    hidden: false
	},
	mplayer = ($('#video-display').length !== 0) ? videojs("video-display") : undefined,

	getNewClip = function() {
	    var clipStart = mplayer.getValueSlider().start,
		clipEnd = mplayer.getValueSlider().end,
		clipFormatStart = videojs.formatTime(clipStart),
		clipFormatEnd = videojs.formatTime(clipEnd),
		clipCanvas = document.createElement('canvas'),
		prevTime = mplayer.currentTime();

	    mplayer.currentTime(mplayer.getValueSlider().start)
		.on('seeked', function() {
		    clipCanvas.getContext('2d').drawImage(mplayer.player().el().firstChild, 0, 0, 75, 75);
		    $('.video-clip-pill').removeClass('clip-active');
		    $('<div/>', { 'class': 'video-clip-pill clip-active', 'data-start': clipStart, 'data-end': clipEnd })
			.append($('<a/>', { 'class': 'add-clip', 'href': 'javascript:void(0)', 'text': '+' })
				.on('click', selectClip))
			.append($('<a/>', { 'class': 'remove-clip', 'href': 'javascript:void(0)', 'text': '-'  })
				.on('click', removeClip))
			.append($('<div/>')
				.append($('<div/>', { 'class': 'clip-time-start', 'text': clipFormatStart }))
				.append($('<div/>', { 'class': 'clip-time-end', 'text': clipFormatEnd }))
			       )
			.css('background-image', 'url(' + clipCanvas.toDataURL() + ')')
			.on('click', setClipSelection)
			.appendTo($('#video-clip-list'));
		    mplayer.currentTime(prevTime).off('seeked');
		    mplayer.setValueSlider(clipEnd, clipEnd + 60);
		})
	},

	selectClip = function() {
	    var element = $(this).parent(),
		clipStart = element.attr('data-start'),
		clipEnd = element.attr('data-end'),
		clipFormatStart = videojs.formatTime(clipStart),
		clipFormatEnd = videojs.formatTime(clipEnd);

	    $('#video-clip-selected .video-clip-pill.clip-active').removeClass('clip-active');
	    $('<div/>', { 'class': 'video-clip-pill clip-active', 'data-start': clipStart, 'data-end': clipEnd })
		.append($('<a/>', { 'class': 'remove-clip', 'href': 'javascript:void(0)', 'text': '-'  })
			.on('click', removeSelectedClip))
		.append($('<div/>')
			.append($('<div/>', { 'class': 'clip-time-start', 'text': clipFormatStart }))
			.append($('<div/>', { 'class': 'clip-time-end', 'text': clipFormatEnd }))
		       )
		.css('background-image', element.css('background-image'))
		.on('click', setClipSelection)
		.appendTo($('#video-clip-selected'));

	    event.stopPropagation();
	},

	removeClip = function () {
	    var element = $(this).parent(),
		clipStart = element.attr('data-start'),
		clipEnd = element.attr('data-end');
	    $('#video-clip-selected').children('[data-start="' + clipStart + '"]').remove();
	    element.remove();
	},
	removeSelectedClip = function () {
	    var element = $(this).parent();
	    element.remove();
	},

	setClipSelection = function() {
	    var element = $(this),
		clipStart = element.attr('data-start'),
		clipEnd = element.attr('data-end');
	    
	    mplayer.setValueSlider(clipStart, clipEnd);
	    mplayer.pause();
	    mplayer.currentTime(clipStart);
	    $('.video-clip-pill').removeClass('clip-active');
	    element.addClass('clip-active');
	};

    if(mplayer) {
	mplayer.rangeslider(options);
    }

    // var cut_hash = {
    // 	2: {
    // 		'dom':  
    // 		'time': [2, 4]
    // 	}
    // };
    // var active = 2;
    
//	$('#video_select_list').sortable();
	// var active = 2;
/*
	function in_selected(start_time, hash){
		// $('#video_cut_list').append();
	}
*/
    
    if(currentPanel !== '#' && currentPanel !== '') {
	$('.nav-tab > .nav-square > li').removeClass('current');
	$('.nav-tab > .nav-square > li').find('a[href="' + currentPanel + '"]').parent().addClass('current');
	$('.tab-panel').removeClass('current');
	$(currentPanel).addClass('current');
    }
    
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

    $('#btn-video-clip').on('click', function(e) {
	$('.tab-panel').removeClass('current');
	$('#video-clip').addClass('current');
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

    $('#user-name').on('click', function(e) {
	$('#user-menu').toggle();
	e.preventDefault();
    });

    $('#btn-add-clip').on('click', function(){
	getNewClip.call(this);
    });
};

$(document).ready(main);

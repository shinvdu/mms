'use strict'

function element_lists() {
    var container = [];
    $('#video-clip-merge').children().each(function(){
	var p = $(this);
	var start  = p.attr('data-start');
	var end  = p.attr('data-end');
	container.push({start: start, end: end});
    })
	return container;
}

var main = function() {
    var currentPanel = document.location.hash,
	options = {
	    hidden: false
	},
	mplayer = ($('#video-display').length !== 0) ? videojs("video-display") : undefined,

	$frame = $('#clip-frame'),
	$frameWrap = $frame.parent(),
	slyOptions = {
	    horizontal: 1,
	    itemNav: 'basic',
	    smart: 1,
	    activateOn: 'click',
	    mouseDragging: 1,
	    touchDragging: 1,
	    releaseSwing: 1,
	    startAt: 1,
	    speed: 300,
	    elasticBounds: 1,
	    easing: 'easeOutExpo',

	    prev: $frameWrap.find('.clip-prev'),
	    next: $frameWrap.find('.clip-next'),
	},

	getNewClip = function() {
	    var clipCanvas,
		newClipItem,
		position,
		clipStart = mplayer.getValueSlider().start,
		clipEnd = mplayer.getValueSlider().end,
		clipDuration = Math.floor(clipEnd) - Math.floor(clipStart),
		clipFormatStart = videojs.formatTime(clipStart),
		clipFormatEnd = videojs.formatTime(clipEnd),
		clipFormatDuration = videojs.formatTime(clipDuration),
		prevTime = mplayer.currentTime(),
		clipStartList = $.map($('#clip-frame li'), function(element) {
		    return Number($(element).attr('data-start'));
		});

	    for(var i = clipStartList.length - 1; i >= 0; i--) {
		if(clipEnd <= clipStartList[i]) {
		    if(i === 0) {
			position = 0;
			break;
		    }
		    continue;
		}
		else {
		    position = i + 1;
		    break;
		}
	    }

	    mplayer.currentTime(mplayer.getValueSlider().start)
		.on('seeked', function() {
		    clipCanvas = $('<canvas width="74" height="48"></canvas>')[0];
		    if(clipCanvas.getContext) {
			clipCanvas.getContext('2d').drawImage(mplayer.player().el().firstChild, 0, 0, 74, 48);
		    }
		    else {
		    }
		    $('#clip-frame li').removeClass('active');
		    newClipItem = $('<li/>', { 'data-start': clipStart, 'data-end': clipEnd })
			.append($('<div/>', { 'class': 'clip-canvas-wraper' })
				.append($(clipCanvas))
				.append($('<div/>')
					.append($('<button/>', { 'class': 'add-clip' })
						.append($('<i/>', { 'class': 'fa fa-plus' }))
						.on('click', selectClip)
					       )
					.append($('<button/>', { 'class': 'remove-clip' })
						.append($('<i/>', { 'class': 'fa fa-minus' }))
						.on('click', removeClip)
					       )
				       )
			       )
			.append($('<div/>', { 'class': 'clip-info' })
				.append($('<span/>', { 'text': clipFormatStart }))
				.append('-')
				.append($('<span/>', { 'text': clipFormatEnd }))
				.append($('<br>'))
				.append($('<span/>', { 'text': clipFormatDuration }))
			       )
			.on('click', setClipSelection)[0];
		    $frame.sly('add', newClipItem, position);
		    $frame.sly('activate', newClipItem);
		    
		    mplayer.currentTime(prevTime).off('seeked');
		    mplayer.setValueSlider(clipEnd, clipEnd + 10);
		})
	},

	selectClip = function() {
	    var element = $(this).closest('li'),
		clipStart = element.attr('data-start'),
		clipEnd = element.attr('data-end'),
		clipDuration = Math.floor(clipEnd) - Math.floor(clipStart),
		clipFormatStart = videojs.formatTime(clipStart),
		clipFormatEnd = videojs.formatTime(clipEnd),
		clipFormatDuration = videojs.formatTime(clipDuration),
		clipCanvas = $('<canvas width="74" height="48"></canvas>')[0];

	    if(clipCanvas.getContext) {
		clipCanvas.getContext('2d').drawImage(element.find('canvas')[0], 0, 0, 74, 48);
	    }
	    else {
	    }

	    $('#video-clip-merge .active').removeClass('active');
	    $('<div/>', { 'class': 'video-clip-pill active', 'data-start': clipStart, 'data-end': clipEnd })
		.append($('<div/>', { 'class': 'clip-canvas-wraper' })
			.append($(clipCanvas))
			.append($('<div/>')
				.append($('<button/>', { 'class': 'remove-clip' })
					.append($('<i/>', { 'class': 'fa fa-minus' }))
					.on('click', removeSelectedClip)
				       )
			       )
		       )
		.append($('<div/>', { 'class': 'clip-info' })
			.append($('<span/>', { 'text': clipFormatStart }))
			.append('-')
			.append($('<span/>', { 'text': clipFormatEnd }))
			.append($('<br>'))
			.append($('<span/>', { 'text': clipFormatDuration }))
		       )
		.on('click', setClipSelection)
		.appendTo($('#video-clip-merge'));
	    
	    event.stopPropagation();
	},

	removeClip = function () {
	    var element = $(this).closest('li'),
		clipStart = element.attr('data-start'),
		clipEnd = element.attr('data-end');
	    $('#video-clip-merge').children('[data-start="' + clipStart + '"]').remove();
	    $frame.sly('remove', element);
	    event.stopPropagation();
	},

	removeSelectedClip = function () {
	    var element = $(this).closest('.video-clip-pill');
	    element.remove();
	    event.stopPropagation();
	},

	setClipSelection = function() {
	    var element = $(this),
		clipStart = element.attr('data-start'),
		clipEnd = element.attr('data-end');
	    
	    mplayer.setValueSlider(clipStart, clipEnd);
	    mplayer.pause();
	    mplayer.currentTime(clipStart);
	    $('#clip-frame li').removeClass('active');
	    $('#video-clip-merge .active').removeClass('active');
	    element.addClass('active');
	    event.stopPropagation();
	};

    $frame.sly(slyOptions);

    if(mplayer) {
	mplayer.rangeslider(options);
    }
    
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

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
	options = {hidden:false},
	mplayer = videojs("video-display");
	mplayer.rangeslider(options);
	$('#video_select_list').sortable();
	// var cut_hash = {
	// 	2: {
	// 		'dom':  
	// 		'time': [2, 4]
	// 	}
	// };
	// var active = 2;

	$(".video-clip-pill").bind('click', function(e){
		set_selection($(this));
	})
	$("#btn-add-clip").bind('click', function(){
		var time = mplayer.getValueSlider();
		var start = Math.floor(time.start);
		var end = Math.floor(time.end);
		get_new_cut_element();
		mplayer.setValueSlider(end, end+5);
	})
	function time_format(time) {
	    var sec_num = parseInt(time, 10); // don't forget the second param
	    var hours   = Math.floor(sec_num / 3600);
	    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
	    var seconds = sec_num - (hours * 3600) - (minutes * 60);

	    if (hours   < 10) {hours   = "0"+hours;}
	    if (minutes < 10) {minutes = "0"+minutes;}
	    if (seconds < 10) {seconds = "0"+seconds;}
	    var time    = hours+':'+minutes+':'+seconds;
	    return time;
	}

	function in_selected(start_time, hash){
		// $('#video_cut_list').append();
	}

	function remove_cut_element(p) {
	          var item = p.parent();
	          var start = item.attr('data-start');
	          var end = item.attr('data-end');
	          $('#video_select_list').children('[data-start=' + start+ ']').remove();
	          remove_self(p); 
	}

	function remove_self (p) {
	          p.parent().remove();

	}

	function select_cut_element(p){
	          var item = p.parent();
	          var start = item.attr('data-start');
	          var end = item.attr('data-end');
	          var dom_head = $('<div></div>').addClass('video-clip-pill').attr('data-start', start).attr('data-end', end);
	          var remove = $('<a href="javascript:void(0)"></a>').append($('<span></span>').addClass('remove').text('-'));
	          remove.bind('click', function(){
	          	remove_self($(this))
		});
	          dom_head.append(remove);
	          var dom_sub = $('<div></div>');
	          var dom_start = $('<div></div>').addClass('clip-number').text(time_format(start));
	          var dom_end = $('<div></div>').addClass('clip-time').text(time_format(end));
	          dom_sub.append(dom_start).append(dom_end);

	          dom_head.append(dom_sub);
	          dom_head.bind("click", function(){
	          	set_selection($(this));
	          })
	          $('#video_select_list').append(dom_head);
	      }

	function get_new_cut_element(){
		$(".cut_active").removeClass('cut_active');
		var time = mplayer.getValueSlider();
		var start = Math.floor(time.start);
		var end = Math.floor(time.end);

		var dom_head = $('<div></div>').addClass('video-clip-pill').addClass('cut_active').attr('data-start', start).attr('data-end', end);
		var add = $('<a href="javascript:void(0)"></a>').append($('<span></span>').addClass('add').text('+'))
		add.bind('click', function(){
		  	// console.log('plus')
		  	select_cut_element($(this))
		  });
		dom_head.append(add);
		var remove = $('<a href="javascript:void(0)"></a>').append($('<span></span>').addClass('remove').text('-'));

		remove.bind('click', function(){
		  	remove_cut_element($(this))
			// console.log('minus')
		});
		dom_head.append(remove)

		var dom_sub = $('<div></div>');
		var dom_start = $('<div></div>').addClass('clip-number').text(time_format(start));
		var dom_end = $('<div></div>').addClass('clip-time').text(time_format(end));
		dom_sub.append(dom_start).append(dom_end);

		dom_head.append(dom_sub);
		dom_head.bind("click", function(){
			set_selection($(this));
		})
		$('#video_cut_list').append(dom_head);
	}

	function set_selection(p){
		var start = p.attr('data-start');
		var end = p.attr('data-end');
		mplayer.setValueSlider(start, end);
		mplayer.pause();
		mplayer.currentTime(start);
		$(".cut_active").removeClass('cut_active');
		p.addClass('cut_active')
		// active = start
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

    $('#btn-add-clip').on('click', {mplayer: mplayer}, function(e) {
	var clipCanvas = document.createElement('canvas');
	clipCanvas.getContext('2d').drawImage(e.data.mplayer.player().el().firstChild, 0, 0, 75, 75);
    });
};

$(document).ready(main);

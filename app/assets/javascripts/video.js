//= require lib/videojs/video.min.js
//= require lib/videojs/videojs.watermark.js
//= require lib/videojs/video-js-resolutions.js
//= require lib/videojs/base64.min.js
//= require lib/jquery.cookie.js
//= require lib/sha1.min.js


function cal_signature(video_id) {
    var session_id = $.cookie('wgcloud_id');
    var video_salt = $.cookie('video_salt');
    var cal_string = session_id + '#' + video_id + '#' + video_salt;
    // console.log(cal_string)
    return hex_sha1(cal_string)
}

jQuery(document).ready(function($) {
    function player_id() {
        return $("#player_id").attr('player')
    }

    function player_init(json) {
        var data_setup = json.init;
        var logo = json.logo;
        var video = videojs("wgcloud_video_1", data_setup);
        if (logo !== undefined) {
            video.watermark(logo);
        }
        load_video(video);
    }

    function load_video(video) {
        var base_string = $("#source").attr('source');
        var sources = JSON.parse(Base64.decode(base_string));
        var video_id = $("#video_id").attr('videoid');
        var signature = cal_signature(video_id);
        sources.map(function(n) {
            n.src = n.src + '&signature=' + signature
        });
        // console.log(sources)
        video.src(sources)

    }

    $.ajax({
        dataType: 'json',
        url: '/players/' + player_id() + '.json',
        success: function(json) {
            player_init(json)
        },
    });
});

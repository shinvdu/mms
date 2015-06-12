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
    return hex_sha1(cal_string)
}

jQuery(document).ready(function($) {
    var videojsid = "wgcloud_video_1";
    var $video = $("#wgcloud_video_1");
    function player_id() {
        return $("#player_id").attr('player')
    }

    function player_init(json) {
        var data_setup = json.init;
        $.extend(data_setup, {
            plugins: {
                resolutions: true
            }
        });
        var logo = json.logo;
        load_video();
        var video = videojs(videojsid, data_setup);
        if (logo !== undefined) {
            video.watermark(logo);
        }
    }

    function load_video() {
        var base_string = $("#source").attr('source');
        var sources = JSON.parse(Base64.decode(base_string));
        var video_id = $("#video_id").attr('videoid');
        var signature = cal_signature(video_id);
        sources.map(function(srouce) {
            srouce.src = srouce.src + '&signature=' + signature
        });
        $.each(sources, function(_, source) {
            var $source = $("<source>").attr("src", source.src).attr("type", source.type).attr("data-res", source["data-res"]);
            $video.children("p").before($source);
        });
    }

    $.ajax({
        dataType: 'json',
        url: '/players/' + player_id() + '.json',
        success: function(json) {
            player_init(json)
        },
    });
});

//= require lib/jqplot/jquery.jqplot.min.js
//= require lib/jqplot/jqplot.dateAxisRenderer.min.js

$(function() {
    var stats = $.parseJSON($('#stats_json').val());
    var user_video_stats = [];
    var mkv_video_stats = [];
    var product_stats = [];
    var max_size = 0;
    $.each(stats, function(_, stat) {
        user_video_stats.push([stat.date, stat.user_video_amount]);
        mkv_video_stats.push([stat.date, stat.mkv_video_amount]);
        product_stats.push([stat.date, stat.product_amount]);
        max_size = Math.max(stat.user_video_amount, stat.mkv_video_amount, stat.product_amount, max_size);
    });
    var s = max_size;
    var unit = 'B';
    var unit_interval = 1;
    if (s > 1024 * 2) {
        s /= 1024;
        unit = 'K';
        unit_interval *= 1024;
    }
    if (s > 1024 * 2) {
        s /= 1024;
        unit = 'M';
        unit_interval *= 1024;
    }
    if (s > 1024 * 2) {
        s /= 1024;
        unit = 'G';
        unit_interval *= 1024;
    }

    $.jqplot('user_video_chart', [
        user_video_stats,
        mkv_video_stats,
        product_stats
    ], {
        title: 'space usage',
        axes: {
            xaxis: {
                renderer: $.jqplot.DateAxisRenderer,
                tickOptions: {formatString: '%#m/%#d'},
                tickInterval: parseInt(user_video_stats.length / 7) + 1 + ' day'
            },
            yaxis: {
                min: 0,
                numberTicks: 10,
                tickInterval: unit_interval * Math.ceil(s / 9),
                tickOptions: {
                    formatter: function(format, value) { return value / unit_interval; },
                    suffix: unit
                }
            }
        }
    });
});

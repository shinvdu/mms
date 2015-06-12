    jQuery(document).ready(function($) {
        ['#transcoding_video_fps', '#video_main_frame_time'].forEach(function(e) {
            $(e).on('change  paste keyup', function() {
                var video_main_frame_time = parseInt($(this).val());
                var fps = parseInt($("#transcoding_video_fps").val());
                var gop = video_main_frame_time * fps;
                $("#transcoding_video_gop").val(gop ? gop : 250);
            });
        });
        $('#scanmode').change(
            function() {
                if ($(this).is(':checked')) {
                    $("#transcoding_video_scanmode").val('interlaced');
                } else {
                    $("#transcoding_video_scanmode").val('progressive');
                }
            });

        $('#width_and').on('change', function(e) {
            var optionSelected = $("option:selected", this);
            var valueSelected = this.value;
            var size = valueSelected.split('|');
            var width = parseInt(size[0]);
            $("#transcoding_width").val(width);
            $("#transcoding_height").val('');

        });

        $('#and_height').on('change', function(e) {
            var optionSelected = $("option:selected", this);
            var valueSelected = this.value;
            var size = valueSelected.split('|');
            var height = parseInt(size[1]);
            $("#transcoding_width").val('');
            $("#transcoding_height").val(height);
        });

        $('#width_and_height').on('change', function(e) {
            var optionSelected = $("option:selected", this);
            var valueSelected = this.value;
            switch (valueSelected) {
                case 'keep':
                $('#item_and_height').hide();
                $('#item_width_and').hide();
                $("#transcoding_width").val('');
                $("#transcoding_height").val('');
                break;
                case 'width':
                $('#item_and_height').hide();
                $('#item_width_and').show();
                $("#transcoding_height").val('');
                $('#width_and').change();
                break;
                case 'height':
                $('#item_width_and').hide();
                $('#item_and_height').show();
                $("#transcoding_width").val('');
                $('#and_height').change();
                break;
                default:
                // n 与 case 1 和 case 2 不同时执行的代码
            }
        });
    });


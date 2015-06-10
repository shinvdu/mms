//= require lib/jquery.form.min.js

(function($) {
    'use strict';
    $.fn.wg_upload = function(args) {
        var options = {
            on_error: false,
            on_success: false
        };
        $.extend(options, args);
        var $form = this;
        var preuploaded = false;
        var uploading = false;

        $(this).on("submit", function(e) {
            if (uploading) {
                e.preventDefault();
                return;
            } else {
                uploading = true;
            }
            if (preuploaded) {
                return;
            } else {
                e.preventDefault();
            }
            var data = {};
            $("input", $form).each(function(_, elem) {
                data[$(elem).attr("name")] = $(elem).val();
            });
            $("select", $form).each(function(_, elem) {
                data[$(elem).attr("name")] = $("option:selected", elem).val();
            });
            $.ajax({
                url: "/user_videos/preupload.json",
                type: "post",
                data: data,
                dataType: "JSON",
                success: function(data, textStatus) {
                    preuploaded = true;
                    console.log(data);
                    do_upload(data.url, data.token);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    preuploaded = false;
                    uploading = false;
                    console.log(textStatus);
                    if (options.on_error)
                        options.on_error(XMLHttpRequest, textStatus, errorThrown);
                }
            });
        });

        function do_upload(url, token) {
            $form.ajaxSubmit({
                    url: url,
                    dataType: "json",
                    data: {token: token},
                    success: function(data, statusText, xhr, $form) {
                        console.log(data);
                        if (options.on_success)
                            options.on_success(data, statusText, xhr, $form);
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        preuploaded = false;
                        uploading = false;
                        console.log(textStatus);
                        if (options.on_error)
                            options.on_error(XMLHttpRequest, textStatus, errorThrown);
                    }
                }
            );
        }
    }
})
(jQuery);

//= require lib/wg/wg_upload.js

$(function() {
    $('#upload_form').wg_upload({
        on_success: function(data, statusText, xhr, $form) {
            alert("成功");
        },
        on_error: function(XMLHttpRequest, textStatus, errorThrown) {
            if (XMLHttpRequest.status == 400) {
                alert(XMLHttpRequest.responseJSON.message)
            } else {
                alert("请求时发生错误");
            }
        }
    });
});

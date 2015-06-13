/*
* //= require lib/cropper/cropper.min.js
* //= require lib/cropper/canvas-to-blob.min.js
* //= require lib/cropper/mlogo.js
*/
/*
$(function() {
    document.querySelector("#logo_form").addEventListener("submit", function(event) {
        event.preventDefault();
        var formData = new FormData(this);
        var canvas = $('.img-container > img').cropper('getCroppedCanvas')

        if (typeof canvas.toBlob !== "undefined") {
            canvas.toBlob(function(blob) {
                formData.append("logo[uri]", blob, $('#logo_file_name').text());
            }, "image/png", 0.75);
        } else if (typeof canvas.msToBlob !== "undefined") {
            var blob = canvas.msToBlob()
            formData.append("logo[uri]", blob, $('#logo_file_name').text());
        }

        $.ajax({
            url: '/logos<%= "/#{@logo.id}" if controller.action_name == 'edit' %>.json',
            data: formData,
            processData: false,
            contentType: false,
            type: 'POST',
            success: function(data) {
                location.href = '<%= logos_path %>/' + data.id;
            },
            error: function(xhr, error) {
                var failed = '<div class="alert alert-danger">上传失败 </div>'
                $('#message').html(failed)
                window.scrollTo(0, 0);
            },
        });
    }, false);

});
*/

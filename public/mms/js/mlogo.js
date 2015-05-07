function readURL(input) {
    if (input.files && input.files[0]) {
        if($('#logo_name').val() == ''){
            $('#logo_name').val(input.files[0].name);
        }
    }
}   
function show_images () {
    $('div.logo_images').show();
}

$(function () {
    'use strict';

    (function () {
        var $image = $('.img-container > img'),
        options = {
            aspectRatio: 12 / 12,
            preview: '.img-preview',
            crop: function (data) {
            // console.log(Math.round(data.x));
            }
        };
    $image.cropper(options);
    // Import image
    var $inputImage = $('#logo_uri'),
        URL = window.URL || window.webkitURL,
        blobURL;

    if (URL) {
        $inputImage.change(function () {
            var files = this.files,
            file;

        if (files && files.length) {
            file = files[0];

            if (/^image\/\w+$/.test(file.type)) {
                blobURL = URL.createObjectURL(file);
                $image.one('built.cropper', function () {
                    URL.revokeObjectURL(blobURL); // Revoke when load complete
                }).cropper('reset', true).cropper('replace', blobURL);
                $inputImage.val('');
            } else {
                showMessage('Please choose an image file.');
            }
        }
        });
    } else {
        $inputImage.parent().remove();
    }


    // Methods
    $(document.body).on('keydown', function (e) {

        switch (e.which) {
            case 37:
                e.preventDefault();
                $image.cropper('move', -2, 0);
                break;

            case 38:
                e.preventDefault();
                $image.cropper('move', 0, -2);
                break;

            case 39:
                e.preventDefault();
                $image.cropper('move', 2, 0);
                break;

            case 40:
                e.preventDefault();
                $image.cropper('move', 0, 2);
                break;
        }

    });

    }());

});
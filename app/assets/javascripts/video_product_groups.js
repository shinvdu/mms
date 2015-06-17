$(function() {
    var removeId;
    $("body").delegate("div.panel-content div.video-list-item button.btn-remove", "click", function() {
        removeId = $(this).closest(".video-list-item").attr("data-id");
        $.get("/video_product_groups/" + removeId + "/last.json", {}, function(data, textStatus) {
            if (data.last)
                confirmOriginDialog.dialog("open");
            else
                confirmProductDialog.dialog("open");
        });
    });

    var removeProductGroup = function(removeOrigin) {
        waitRemoveDialog.dialog("open");
        $.post("/video_product_groups/" + removeId, {
            _method: 'delete',
            remove_origin: removeOrigin
        }, function(data, textStatus) {
            location.reload();
        }, 'json');
    };

    var confirmOriginDialog = $(".confirm-origin-dialog").dialog({
        resizable: false,
        autoOpen: false,
        height: 140,
        modal: true,
        buttons: {
            delte_origin: function() {
                $(this).dialog("close");
                removeProductGroup(true);
            },
            keep_origin: function() {
                $(this).dialog("close");
                removeProductGroup(false);
            },
            abort_operation: function() {
                $(this).dialog("close");
            }
        }
    });

    var confirmProductDialog = $(".confirm-product-dialog").dialog({
        resizable: false,
        autoOpen: false,
        height: 140,
        modal: true,
        buttons: {
            conform_delete: function() {
                $(this).dialog("close");
                removeProductGroup(false);
            },
            cancel: function() {
                $(this).dialog("close");
            }
        }
    });

    var waitRemoveDialog = $(".wait-remove-dialog").dialog({
        resizable: false,
        autoOpen: false,
        height: 140,
        modal: true
    });
});

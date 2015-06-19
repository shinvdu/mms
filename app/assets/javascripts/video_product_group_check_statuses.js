//= require lib/lightbox.min.js

$(function() {
    $("nav.panel-table-pagination ul.pagination li a").each(function(_, e) {
        $(e).attr("data-no-turbolink", true);
    });
});

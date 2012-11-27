/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
function checkExpand(ch) {
    var obj=document.all && document.all(ch) || document.getElementById && document.getElementById(ch);
    if(obj && obj.style) obj.style.display=
    "none" == obj.style.display ?"" : "none"
}

// Change Location of pulldown.
$(document).ready(function() {
    $('#template_area').insertBefore($('#issue_subject').parent());
});

function load_template(template, target_url, token) {
    if (template != "") {
        $.ajax({
            url:target_url,
            async:true,
            data:'issue_template=' + encodeURIComponent(template) + '&authenticity_token='
                + encodeURIComponent(token)
        }).done(function (html) {
                eval("var template = " + html);
                $('#issue_description').val(template.issue_template.description);
                $('#issue_subject').val(template.issue_template.issue_title);
            });
    }
}

function set_pulldown(tracker, target_url, token) {
    $.ajax({
        url: target_url,
        async: true,
        data:"issue_tracker_id=" + encodeURIComponent(tracker) + '&authenticity_token='
            + encodeURIComponent(token)
    }).done(function( html ) {
            $('#issue_template').html(html);
    });
}
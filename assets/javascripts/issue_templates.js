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

function load_template(target_url, token) {
    if (template == "") {
    } else $.ajax({
        url:target_url,
        async:true,
        type:'post',
        data:$.param({issue_tracker_id:$("#issue_template").val(), authenticity_token:token})
    }).done(function (html) {
            eval("var template = " + html);
            $("#issue_description").val(template.issue_template.description);
            $("#issue_subject").val(template.issue_template.issue_title);
        });
}

function set_pulldown(target_url, token) {
    $.ajax({
        url: target_url,
        async: true,
        type: 'post',
        data: $.param({issue_tracker_id: $("#issue_tracker_id").val(), authenticity_token: token})
    }).done(function( html ) {
            $('#issue_template').html(html);
    });
}
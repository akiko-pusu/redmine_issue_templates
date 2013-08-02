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

// TODO: When update description, confirmation dialog should be appeared.
function load_template(target_url, token, confirm_msg) {
    var allow_overwrite = $('#allow_overwrite_description').prop('checked');
    if ($("#issue_template").val() != "") {
        $.ajax({
            url:target_url,
            async:true,
            type:'post',
            data:$.param({issue_template:$("#issue_template").val(), authenticity_token:token})
        }).done(function (html) {
                oldSubj = "";
                oldVal = "";
                eval('var template = ' + html);
                if ($("#issue_description").val() != '') {
                    oldVal = $("#issue_description").val() + "\n\n";
                }

                if ($("#issue_subject").val() != '') {
                    oldSubj = $("#issue_subject").val() + ' ';
                }
                template.issue_template.description = (template.issue_template.description == null)? '' : template.issue_template.description;
                template.issue_template.issue_title = (template.issue_template.issue_title == null)? '' : template.issue_template.issue_title;

                $("#issue_description").val(oldVal + template.issue_template.description);
                $("#issue_subject").val(oldSubj + template.issue_template.issue_title);
                try {
                    if (CKEDITOR.instances.issue_description)
                        CKEDITOR.instances.issue_description.setData(oldVal + template.issue_template.description);
                } catch(e) {
                    // do nothing.
                }
            });
    }
}

function set_pulldown(tracker, target_url, token) {
    var allow_overwrite = $('#allow_overwrite_description').prop('checked');
    $.ajax({
        url: target_url,
        async: true,
        type: 'post',
        data: $.param({issue_tracker_id: tracker, authenticity_token: token})
    }).done(function( html ) {
        $('#issue_template').html(html);
        $('#allow_overwrite_description').attr("checked", allow_overwrite);
    });
}

(function($) {
    $.fn.flash_message = function(options) {
        // default
        options = $.extend({
            text: 'Done',
            time: 2000,
            how: 'before',
            class_name: ''
        }, options);

        return $(this).each(function() {
            if ($(this).parent().find('.flash_message').get(0)) return;

             var message = $('<div />', {
                'class': 'flash_message ' + options.class_name,
                text: options.text
                // display with fade in
            }).hide().fadeIn('fast');

            $(this)[options.how](message);
            //delay and fadeout
            message.delay(options.time).fadeOut('normal', function() {
                $(this).remove();
            });

        });
    };
})(jQuery);
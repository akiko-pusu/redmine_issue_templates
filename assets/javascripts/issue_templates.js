/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
changeType = '';

function checkExpand(ch) {
    var obj=document.all && document.all(ch) || document.getElementById && document.getElementById(ch);
    if(obj && obj.style) obj.style.display=
        'none' === obj.style.display ?'' : 'none'
}

function eraseSubjectAndDescription() {
    $('#issue_description').val('');
    $('#issue_subject').val('');

    try {
        if (CKEDITOR.instances.issue_description)
            CKEDITOR.instances.issue_description.setData('');
    } catch(e) {
        // do nothing.
    }
}

function openDialog(url, title) {
    // ダイアログを表示する

    var request_url = url;
    $.ajax({
        url: request_url,
        success: function (data) {
            $("#filtered_templates_list").html(data);
            $("#issue_template_dialog").dialog(
                {
                    modal: true,
                    dialogClass: "modal overflow_dialog",
                    draggable: true,
                    title: title,
                    width: 400
                }
            );
        }
    });
}

function showUrlInDialog(url, title) {
    var request_url = url;
    $.ajax({
        url: request_url,
        success: function (data) {
            $("#issue_template_dialog").dialog({
                modal: true,
                title: title
            });
            $("#filtered_templates_list").html(data);
        }
    });
}

// TODO: When update description, confirmation dialog should be appeared.
function load_template(target_url, confirm_msg, should_replaced) {
    var selected_template = $('#issue_template');
    if (selected_template.val() !== '') {
        var template_type = '';
        if(selected_template.find('option:selected').hasClass('global')){
            template_type = 'global';
        }
        $.ajax({
            url:target_url,
            async:true,
            type:'post',
            data:$.param({issue_template:selected_template.val(), template_type:template_type})
        }).done(function (data) {
            var oldSubj = '';
            var oldVal = '';
            var issue_subject = $('#issue_subject');
            var issue_description = $('#issue_description');

            var template = JSON.parse(data);
            if (issue_description.val() !== '' && should_replaced === 'false') {
                oldVal = issue_description.val() + '\n\n';
            }

            if (issue_subject.val() !== '' && should_replaced === 'false') {
                oldSubj = issue_subject.val() + ' ';
            }
            for(var issue_template in template) {
                if ({}.hasOwnProperty.call(template, issue_template)) {

                    template[issue_template].description = (template[issue_template].description === null) ? '' : template[issue_template].description;
                    template[issue_template].issue_title = (template[issue_template].issue_title === null) ? '' : template[issue_template].issue_title;

                    issue_description.val(oldVal + template[issue_template].description);
                    issue_subject.val(oldSubj + template[issue_template].issue_title);
                    try {
                        if (CKEDITOR.instances.issue_description)
                            CKEDITOR.instances.issue_description.setData(oldVal + template[issue_template].description);
                    } catch (e) {
                        // do nothing.
                    }
                    // show message just after default template loaded.
                    if (confirm_msg)
                        show_loaded_message(confirm_msg, issue_description);
                }
            }
        });
    }
}

function show_loaded_message(confirm_msg, target) {
    var template_status_area = $('#template_status-area');
    template_status_area.insertBefore(target);
    template_status_area.flash_message({
        text: confirm_msg,
        how: 'append'
    });
}

function set_pulldown(tracker, target_url) {
    var allow_overwrite = $('#allow_overwrite_description').prop('checked');
    $.ajax({
        url: target_url,
        async: true,
        type: 'post',
        data: $.param({issue_tracker_id: tracker})
    }).done(function(data) {
        $('#issue_template').html(data);
        $('#allow_overwrite_description').attr('checked', allow_overwrite);
    });
}

function updateSelect(id, is_global) {
    var target = $('#issue_template');
    if (is_global === true) {
        target = $('#issue_template option[value="' + id + '"][class="global"]').attr("selected", "selected");
        target.change();
    } else {
        target.val(id).trigger('change');
    }
}

// flash message as a jQuery Plugin
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

            var message = $('<div></div>', {
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


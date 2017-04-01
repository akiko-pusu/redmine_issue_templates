/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
changeType = '';

function checkExpand(ch) {
    var obj;
    obj = document.all && document.all(ch) || document.getElementById && document.getElementById(ch);
    if (obj && obj.style) obj.style.display =
        obj.style.display === 'none' ? '' : 'none'
}

function eraseSubjectAndDescription() {
    $('#issue_description').val('');
    $('#issue_subject').val('');

    try {
        if (CKEDITOR.instances.issue_description)
            CKEDITOR.instances.issue_description.setData('');
    } catch (e) {
        // do nothing.
    }
}

function openDialog(url, title) {
    // ダイアログを表示する
    $.ajax({
        url: url,
        success: function (data) {
            $("#filtered_templates_list").html(data);
            $("#issue_template_dialog").dialog(
                {
                    modal: true,
                    dialogClass: "modal overflow_dialog",
                    draggable: true,
                    title: title,
                    minWidth: 400,
                    width: 'auto',
                    maxWidth: 'auto'
                }
            );
        }
    });
}

function load_template(target_url, confirm_msg, should_replaced) {
    var selected_template = $('#issue_template');
    if (selected_template.val() !== '') {
        var template_type = '';
        if (selected_template.find('option:selected').hasClass('global')) {
            template_type = 'global';
        }
        $.ajax({
            url: target_url,
            async: true,
            type: 'post',
            data: $.param({issue_template: selected_template.val(), template_type: template_type})
        }).done(function (data) {
            // NOTE: Workaround for GiHub Issue, to prevent overwrite with default template
            // when operator submits new issue form without required field and returns
            // with error message. If flash message #errorExplanation exists, not overwrited.
            // (https://github.com/akiko-pusu/redmine_issue_templates/issues/50)
            if ($('#errorExplanation')[0]) return;

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
            for (var issue_template in template) {
                if ({}.hasOwnProperty.call(template, issue_template)) {

                    var obj = template[issue_template];
                    obj.description = (obj.description === null) ? '' : obj.description;
                    obj.issue_title = (obj.issue_title === null) ? '' : obj.issue_title;

                    if(oldVal.replace(/(?:\r\n|\r|\n)/g, '').trim() != obj.description.replace(/(?:\r\n|\r|\n)/g, '').trim())
                        issue_description.val(oldVal + obj.description);
                    if(oldSubj.trim() != obj.issue_title.trim())
                        issue_subject.val(oldSubj + obj.issue_title);

                    try {
                        if (CKEDITOR.instances.issue_description)
                            CKEDITOR.instances.issue_description.setData(oldVal + template[issue_template].description);
                    } catch (e) {
                        // do nothing.
                    }
                    // show message just after default template loaded.
                    if (confirm_msg)
                        show_loaded_message(confirm_msg, issue_description);
                    addCheckList(obj);
                }
            }
        });
    }
}

function addCheckList(obj) {
    var list = obj.checklist;
    if (list === undefined) return false;
    if ($('#checklist_form').length === 0) return;

    // remove exists checklist items
    var oldList = $('span.checklist-item.show:visible span.checklist-show-only.checklist-remove > a.icon.icon-del');
    oldList.each(function () {
        oldList.click();
    });

    for (var i = 0; i < list.length; i++) {
        $('span.checklist-new.checklist-edit-box > input.edit-box').val(list[i]);
        $("span.checklist-item.new > span.icon.icon-add.save-new-by-button").click();
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
    }).done(function (data) {
        $('#issue_template').html(data);
        $('#allow_overwrite_description').attr('checked', allow_overwrite);
    });
}

function updateSelect(id, is_global) {
    var target = $('#issue_template');
    target.attr("selected", false);
    if (is_global === true) {
        target.find('option[value="' + id + '"][class="global"]').prop('selected', true);
    } else {
        target.val(id);
    }
    target.trigger('change');
}

// flash message as a jQuery Plugin
(function ($) {
    $.fn.flash_message = function (options) {
        // default
        options = $.extend({
            text: 'Done',
            time: 2500,
            time: 3000,
            how: 'before',
            class_name: ''
        }, options);

        return $(this).each(function () {
            if ($(this).parent().find('.flash_message').get(0)) return;

            var message = $('<div></div>', {
                'class': 'flash_message ' + options.class_name,
                text: options.text
                // display with fade in
            }).hide().fadeIn('fast');

            $(this)[options.how](message);
            //delay and fadeout
            message.delay(options.time).fadeOut('normal', function () {
                $(this).remove();
            });

        });
    };
})(jQuery);


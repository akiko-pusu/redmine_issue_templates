/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// For namespace setting.
var ISSUE_TEMPLATE = ISSUE_TEMPLATE || function() {};
ISSUE_TEMPLATE.prototype = {
    eraseSubjectAndDescription: function() {
        $('#issue_description').val('');
        $('#issue_subject').val('');

        try {
            if (CKEDITOR.instances.issue_description)
                CKEDITOR.instances.issue_description.setData('');
        } catch (e) {
            // do nothing.
        }
    },
    openDialog: function(url, title) {
        // Open dialog (modal window) to display selectable templates list.
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
    },
    revertAppliedTemplate: function () {
        var issue_subject = $('#issue_subject');
        var issue_description = $('#issue_description');
        var old_subject = $('#original_subject');
        var old_description = $('#original_description');
        var templateNS = this;

        issue_subject.val(templateNS.unescapeHTML(old_subject.text()));
        issue_description.val(templateNS.unescapeHTML(old_description.text()));
        old_description.text = '';
        old_description.text = '';
        $('#revert_template').addClass('disabled');
    },
    load_template: function(target_url, confirm_msg, should_replaced,
                            confirm_to_replace, confirmation, general_text_Yes, general_text_No) {
        var selected_template = $('#issue_template');
        var ns = this;
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
                $('#original_subject').text(ns.escapeHTML(issue_subject.val()));
                $('#original_description').text(ns.escapeHTML(issue_description.val()));

                for (var issue_template in template) {
                    if ({}.hasOwnProperty.call(template, issue_template)) {

                        var obj = template[issue_template];
                        obj.description = (obj.description === null) ? '' : obj.description;
                        obj.issue_title = (obj.issue_title === null) ? '' : obj.issue_title;

                        if (confirm_to_replace !== true && should_replaced === 'true' && (issue_description.val() !== '' || issue_subject.val() !== '')) {
                            if (oldVal !== obj.description || oldSubj !== obj.issue_title) {
                                ns.confirmToReplace(target_url, confirm_msg, should_replaced, confirmation, general_text_Yes, general_text_No);
                                return;
                            }
                        }

                        issue_description.attr('original_description', $('<div />').text(issue_description.val()).html());
                        issue_subject.attr('original_title', $('<div />').text(issue_subject.val()).html());

                        if (oldVal.replace(/(?:\r\n|\r|\n)/g, '').trim() != obj.description.replace(/(?:\r\n|\r|\n)/g, '').trim())
                            issue_description.val(oldVal + obj.description);
                        if (oldSubj.trim() != obj.issue_title.trim())
                            issue_subject.val(oldSubj + obj.issue_title);

                        try {
                            if (CKEDITOR.instances.issue_description)
                                CKEDITOR.instances.issue_description.setData(oldVal + template[issue_template].description);
                        } catch (e) {
                            // do nothing.
                        }
                        // show message just after default template loaded.
                        if (confirm_msg)
                            ns.show_loaded_message(confirm_msg, issue_description);
                        ns.addCheckList(obj);

                        if ($('#original_subject').text().length > 0 || $('#original_description').text().length > 0) {
                            $('#revert_template').removeClass('disabled');
                        }
                    }
                }
            });
        }
    },
    confirmToReplace: function(target_url, confirm_msg, should_replaced,
                                confirmation, general_text_Yes, general_text_No) {
        var ns = this;
        $("#issue_template_confirm_to_replace_dialog").dialog(
            {
                modal: true,
                dialogClass: "modal overflow_dialog",
                draggable: true,
                title: confirmation,
                width: 400,
                buttons: [
                    {
                        text: general_text_Yes,
                        click: function () {
                            $(this).dialog("close");
                            ns.load_template(target_url, confirm_msg, should_replaced, true, confirmation, general_text_Yes, general_text_No)
                        }
                    },
                    {
                        text: general_text_No,
                        click: function () {
                            $(this).dialog("close");
                        }
                    }]
            }
        );
    },
    show_loaded_message: function(confirm_msg, target) {
        var template_status_area = $('#template_status-area');
        template_status_area.insertBefore(target);
        template_status_area.issueTemplate('flash_message', {
            text: confirm_msg,
            how: 'append'
        });
    },
    set_pulldown: function(tracker, target_url) {
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
    },
    addCheckList: function(obj) {
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
    },
    escapeHTML: function(val) {
        return $('<div>').text(val).html();
    },
    unescapeHTML: function(val) {
        return $('<div>').html(val).text();
    }
};


// jQuery plugin for issue template
;(function ($) {
    var methods = {
        init: function (options) {
        },
        updateTemplateSelect: function (options) {
            options = $.extend({
                target: '#issue_template',
                template_id: 'data-issue-template-id'
            }, options);
            return $(this).each(function () {
                $(this).click(function () {
                    var obj = $(options.target);
                    var id = $(this).attr(options.template_id);
                    obj.attr("selected", false);
                    // has template-global class?
                    if ($(this).hasClass('template-global')) {
                        obj.find('option[value="' + id + '"][class="global"]').prop('selected', true);
                    } else {
                        obj.val(id);
                    }
                    obj.trigger('change');
                });
            });
        },
        expandHelp: function (options) {
            options = $.extend({
                attr_name: 'data-template-help-target'
            }, options);
            return $(this).each(function () {
                $(this).click(function () {
                    var target = $(this).attr(options.attr_name);
                    var obj = $(target);
                    if (obj.length)
                        obj.toggle();
                });
            });
        },
        flash_message: function (options) {
            // default
            options = $.extend({
                text: 'Done',
                time: 3000,
                how: 'before',
                class_name: ''
            }, options);

            return $(this).each(function () {
                if ($(this).parent().find('.flash_message').get(0)) return;

                var message = $('<div></div>', {
                    'class': 'flash_message ' + options.class_name,
                    html: options.text
                    // display with fade in
                }).hide().fadeIn('fast');

                $(this)[options.how](message);
                //delay and fadeout
                message.delay(options.time).fadeOut('normal', function () {
                    $(this).remove();
                });

            });
        },
        disabled_link: function (options) {
            options = $.extend({ }, options);
            return $(this).each(function () {
                $(this).click(function (event) {
                    title = event.target.title;
                    if (title.length && event.target.hasAttribute('disabled')) {
                      event.stopPropagation();
                      alert(title);
                      return false;
                    }
                });
            });
        }
    };

    $.fn.issueTemplate = function (method) {

        // Method dispatch logic
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.issueTemplate');
        }
    };
})(jQuery);

$(function () {
    // set plugin
    $('a.template-help').issueTemplate('expandHelp');
    $('a.template-help.collapsible').click(function () {
        $(this).toggleClass('collapsed');
    });

    $('a.template-disabled-link').issueTemplate('disabled_link');

    // display orphaned template list
    $('#orphaned_template_link').on({
        'ajax:success': (function (_this) {
            return function (e, data) {
                $('#orphaned_templates').toggle();
                return $('#orphaned_templates').html(data);
            };
        })(this)
    });
});


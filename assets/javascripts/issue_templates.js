/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
function ISSUE_TEMPLATE(config) {
  this.pulldownUrl = config.pulldownUrl
  this.loadUrl = config.loadUrl
  this.confirmMsg = config.confirmMessage
  this.shouldReplaced = config.shouldReplaced
  this.confirmation = config.confirmation
  this.generalTextYes = config.generalTextYes
  this.generalTextNo = config.generalTextNo
  this.isTriggeredBy = config.isTriggeredBy
  this.confirmToReplace = true
}

ISSUE_TEMPLATE.prototype = {
  eraseSubjectAndDescription: function () {
    $('#issue_description').val('')
    $('#issue_subject').val('')

    try {
      if (CKEDITOR.instances.issue_description) {
        CKEDITOR.instances.issue_description.setData('')
      }
    } catch (e) {
      // do nothing.
    }
  },
  openDialog: function (url, title) {
    // Open dialog (modal window) to display selectable templates list.
    $.ajax({
      url: url,
      success: function (data) {
        $('#filtered_templates_list').html(data)
        $('#issue_template_dialog').dialog({
          modal: true,
          dialogClass: 'modal overflow_dialog',
          draggable: true,
          title: title,
          minWidth: 400,
          width: 'auto',
          maxWidth: 'auto'
        })
      }
    })
  },
  revertAppliedTemplate: function () {
    let issueSubject = $('#issue_subject')
    let issueDescription = $('#issue_description')
    let oldSubject = $('#original_subject')
    let oldDescription = $('#original_description')
    let templateNS = this

    issueSubject.val(templateNS.unescapeHTML(oldSubject.text()))
    issueDescription.val(templateNS.unescapeHTML(oldDescription.text()))

    try {
      if (CKEDITOR.instances.issue_description)
        CKEDITOR.instances.issue_description.setData(templateNS.unescapeHTML(oldDescription.text()))
    } catch (e) {
      // do nothing.
    }
    oldDescription.text = ''
    oldDescription.text = ''
    $('#revert_template').addClass('disabled')
  },
  loadTemplate: function () {
    let selectedTemplate = $('#issue_template')
    let ns = this
    if (selectedTemplate.val() !== '') {
      let templateType = ''
      if (selectedTemplate.find('option:selected').hasClass('global')) {
        templateType = 'global'
      }
      $.ajax({
        url: ns.loadUrl,
        async: true,
        type: 'post',
        data: $.param({
          template_id: selectedTemplate.val(),
          template_type: templateType
        })
      }).done(function (data) {
        // NOTE: Workaround for GiHub Issue, to prevent overwrite with default template
        // when operator submits new issue form without required field and returns
        // with error message. If flash message #errorExplanation exists, not overwrited.
        // (https://github.com/akiko-pusu/redmine_issue_templates/issues/50)
        if ($('#errorExplanation')[0]) return

        let oldSubj = ''
        let oldVal = ''
        let issueSubject = $('#issue_subject')
        let issueDescription = $('#issue_description')

        let template = JSON.parse(data)

        if (issueDescription.val() !== '' && ns.shouldReplaced === 'false') {
          oldVal = issueDescription.val() + '\n\n'
        }

        if (issueSubject.val() !== '' && ns.shouldReplaced === 'false') {
          oldSubj = issueSubject.val() + ' '
        }
        $('#original_subject').text(ns.escapeHTML(issueSubject.val()))
        $('#original_description').text(ns.escapeHTML(issueDescription.val()))

        for (let issueTemplate in template) {
          if ({}.hasOwnProperty.call(template, issueTemplate)) {
            let obj = template[issueTemplate]
            obj.description = (obj.description === null) ? '' : obj.description
            obj.issue_title = (obj.issue_title === null) ? '' : obj.issue_title

            if (ns.confirmToReplace === true && ns.shouldReplaced === 'true' && (issueDescription.val() !== '' || issueSubject.val() !== '')) {
              if (oldVal !== obj.description || oldSubj !== obj.issue_title) {
                let hideConfirmFlag = ns.hideOverwiteConfirm()
                if (hideConfirmFlag === false) {
                  ns.confirmToReplaceContent(ns.loadUrl)
                  return
                }
              }
            }

            issueDescription.attr('original_description', $('<div />').text(issueDescription.val()).html())
            issueSubject.attr('original_title', $('<div />').text(issueSubject.val()).html())

            if (oldVal.replace(/(?:\r\n|\r|\n)/g, '').trim() !== obj.description.replace(/(?:\r\n|\r|\n)/g, '').trim()) {
              issueDescription.val(oldVal + obj.description)
            }
            if (oldSubj.trim() !== obj.issue_title.trim()) {
              issueSubject.val(oldSubj + obj.issue_title)
            }

            try {
              if (CKEDITOR.instances.issue_description) {
                CKEDITOR.instances.issue_description.setData(oldVal + template[issueTemplate].description)
              }
            } catch (e) {
              // do nothing.
            }
            // show message just after default template loaded.
            if (ns.confirmMsg) {
              ns.showLoadedMessage(issueDescription)
            }
            ns.addCheckList(obj)
            ns.confirmToReplace = true

            if ($('#original_subject').text().length > 0 || $('#original_description').text().length > 0) {
              $('#revert_template').removeClass('disabled')
            }
          }
        }
      })
    }
  },
  confirmToReplaceContent: function () {
    let ns = this
    $('#issue_template_confirm_to_replace_dialog').dialog({
      modal: true,
      dialogClass: 'modal overflow_dialog',
      draggable: true,
      title: ns.confirmation,
      width: 400,
      buttons: [
        {
          text: ns.generalTextYes,
          click: function () {
            $(this).dialog('close')
            ns.confirmToReplace = false
            ns.loadTemplate(ns.loadUrl)
          }
        },
        {
          text: ns.generalTextNo,
          click: function () {
            $(this).dialog('close')
          }
        }
      ]
    })
  },
  showLoadedMessage: function (target) {
    let ns = this
    let templateStatusArea = $('#template_status-area')
    templateStatusArea.insertBefore(target)
    templateStatusArea.issueTemplate('flash_message', {
      text: ns.confirmMsg,
      how: 'append'
    })
  },
  setPulldown: function (tracker) {
    let ns = this
    let allowOverwrite = $('#allow_overwrite_description').prop('checked')
    $.ajax({
      url: ns.pulldownUrl,
      async: true,
      type: 'post',
      data: $.param({
        issue_tracker_id: tracker
      })
    }).done(function (data) {
      $('#issue_template').html(data)
      $('#allow_overwrite_description').attr('checked', allowOverwrite)
    })
  },
  addCheckList: function (obj) {
    let list = obj.checklist
    if (list === undefined) return false
    if ($('#checklist_form').length === 0) return

    // remove exists checklist items
    let oldList = $('span.checklist-item.show:visible span.checklist-show-only.checklist-remove > a.icon.icon-del')
    oldList.each(function () {
      oldList.click()
    })

    for (let i = 0; i < list.length; i++) {
      $('span.checklist-new.checklist-edit-box > input.edit-box').val(list[i])
      $("span.checklist-item.new > span.icon.icon-add.save-new-by-button").click()
    }
  },
  escapeHTML: function (val) {
    return $('<div>').text(val).html()
  },
  unescapeHTML: function (val) {
    return $('<div>').html(val).text()
  },
  replaceCkeContent: function () {
    return CKEDITOR.instances.issue_description.setData($('#issue_description').val())
  },
  hideOverwiteConfirm: function () {
    let cookieArray = []
    if (document.cookie !== '') {
      let tmp = document.cookie.split(' ')
      for (let i = 0; i < tmp.length; i++) {
        let data = tmp[i].split('=')
        cookieArray[data[0]] = decodeURIComponent(data[1])
      }
    }
    let confirmationCookie = cookieArray['issue_template_confirm_to_replace_hide_dialog']
    if (confirmationCookie == undefined || parseInt(confirmationCookie) === 0) {
      return false
    }
    return true
  },
  changeTemplatePlace: function () {
    if (document.querySelector('div.flash_message')) {
      document.querySelector('div.flash_message').remove()
    }
    const subjectNode = document.getElementById('issue_subject')
    if (subjectNode) {
      const subjectParentNode = subjectNode.parentNode
      subjectParentNode.parentNode.insertBefore(document.getElementById('template_area'), subjectParentNode)
    }
  }
};

// jQuery plugin for issue template
(function ($) {
  let methods = {
    init: function (options) {},
    updateTemplateSelect: function (options) {
      options = $.extend({
        target: '#issue_template',
        template_id: 'data-issue-template-id'
      }, options)
      return $(this).each(function () {
        $(this).click(function () {
          let obj = $(options.target)
          let id = $(this).attr(options.template_id)
          obj.attr('selected', false)
          // has template-global class?
          if ($(this).hasClass('template-global')) {
            obj.find('option[value="' + id + '"][class="global"]').prop('selected', true)
          } else {
            obj.val(id)
          }
          obj.trigger('change')
        })
      })
    },
    displayTooltip: function (options) {
      options = $.extend({
        tooltip_body_id: 'data-tooltip-content',
        tooltip_target_id: 'data-tooltip-area'
      }, options)
      return $(this).each(function () {
        $(this).hover(function () {
          let content = $(this).attr(options.tooltip_body_id)
          let target = $(this).attr(options.tooltip_target_id)
          let obj = $(content)
          if (obj.length) {
            $(target).html(obj)
          }
          obj.toggle()
        })
      })
    },
    expandHelp: function (options) {
      options = $.extend({
        attr_name: 'data-template-help-target'
      }, options)
      return $(this).each(function () {
        $(this).click(function () {
          let target = $(this).attr(options.attr_name)
          let obj = $(target)
          if (obj.length) {
            obj.toggle()
          }
        })
      })
    },
    flash_message: function (options) {
      // default
      options = $.extend({
        text: 'Done',
        time: 3000,
        how: 'before',
        class_name: ''
      }, options)

      return $(this).each(function () {
        if ($(this).parent().find('.flash_message').get(0)) return

        let message = $('<div></div>', {
          'class': 'flash_message ' + options.class_name,
          html: options.text
          // display with fade in
        }).hide().fadeIn('fast')

        $(this)[options.how](message)
        //delay and fadeout
        message.delay(options.time).fadeOut('normal', function () {
          $(this).remove()
        })
      })
    },
    disabled_link: function (options) {
      options = $.extend({}, options)
      return $(this).each(function () {
        $(this).click(function (event) {
          let title = event.target.title
          if (title.length && event.target.hasAttribute('disabled')) {
            event.stopPropagation()
            window.alert(title)
            return false
          }
        })
      })
    }
  }

  $.fn.issueTemplate = function (method) {

    // Method dispatch logic
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('Method ' + method + ' does not exist on jQuery.issueTemplate')
    }
  }
})(jQuery)

$(function () {
  // set plugin
  $('a.template-help').issueTemplate('displayTooltip')
  $('a.template-help.collapsible').issueTemplate('expandHelp')
  $('a.template-help.collapsible').click(function () {
    $(this).toggleClass('collapsed')
  })

  $('a.template-disabled-link').issueTemplate('disabled_link')

  // display orphaned template list
  $('#orphaned_template_link').on(
    'ajax:success',
    function (e) {
      let xhr = e.detail[2]
      $('#orphaned_templates').toggle()
      $('#orphaned_templates').html(xhr.response)
    }
  )
})

// for IE11 compatibility (IE11 does not support native Element.closest)
// Ref. https://developer.mozilla.org/en-US/docs/Web/API/Element/closest#Polyfill
// Ref. https://github.com/akiko-pusu/redmine_issue_templates/issues/270
if (!Element.prototype.matches) {
  Element.prototype.matches = Element.prototype.msMatchesSelector ||
    Element.prototype.webkitMatchesSelector
}

if (!Element.prototype.closest) {
  Element.prototype.closest = function (s) {
    let el = this

    do {
      if (el.matches(s)) return el
      el = el.parentElement || el.parentNode
    } while (el !== null && el.nodeType === 1)
    return null
  }
}

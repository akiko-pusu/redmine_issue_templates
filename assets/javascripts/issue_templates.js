/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// For namespace setting.
var ISSUE_TEMPLATE = ISSUE_TEMPLATE || function () {}

ISSUE_TEMPLATE.prototype = {
  clearValue: (id) => {
    let target = document.getElementById(id)
    if (target === null) {
      return
    }
    target.value = ''
  },
  eraseSubjectAndDescription: function () {
    this.clearValue('issue_description')
    this.clearValue('issue_subject')

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
        document.getElementById('filtered_templates_list').innerHTML = data
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
    let issueSubject = document.getElementById('issue_subject')
    let oldSubject = document.getElementById('original_subject')

    let issueDescription = document.getElementById('issue_description')
    let oldDescription = document.getElementById('original_description')
    let templateNS = this

    issueSubject.value = templateNS.unescapeHTML(oldSubject.textContent)

    if (issueDescription !== null) {
      issueDescription.value = templateNS.unescapeHTML(oldDescription.textContent)
    }

    try {
      if (CKEDITOR.instances.issue_description) {
        CKEDITOR.instances.issue_description.setData(templateNS.unescapeHTML(oldDescription.text()))
      }
    } catch (e) {
      // do nothing.
    }
    oldDescription.textContent = ''
    oldDescription.textContent = ''
    document.getElementById('revert_template').classList.add('disabled')
  },
  load_template: function (targetUrl, confirmMsg, shouldReplaced,
    confirmToReplace, confirmation, generalTextYes, generalTextNo) {
    // let selectedTemplate = $('#issue_template')
    let selectedTemplate = document.getElementById('issue_template')
    let ns = this

    if (selectedTemplate.value !== '') {
      let templateType = ''
      let selectedOption = selectedTemplate.options[selectedTemplate.selectedIndex]
      if (selectedOption.classList.contains('global')) {
        templateType = 'global'
      }
      $.ajax({
        url: targetUrl,
        async: true,
        type: 'post',
        data: $.param({
          template_id: selectedTemplate.value,
          template_type: templateType
        })
      }).done(function (data) {
        // NOTE: Workaround for GiHub Issue, to prevent overwrite with default template
        // when operator submits new issue form without required field and returns
        // with error message. If flash message #errorExplanation exists, not overwrited.
        // (https://github.com/akiko-pusu/redmine_issue_templates/issues/50)
        if (document.querySelector('#errorExplanation') && document.querySelector('#errorExplanation')[0]) return

        // Returned JSON may have the key named 'global_template' or 'issue_template'
        let parsedData = JSON.parse(data)
        let templateKey = Object.keys(parsedData)[0]
        let obj = parsedData[templateKey]

        obj.description = (obj.description === null) ? '' : obj.description
        obj.issue_title = (obj.issue_title === null) ? '' : obj.issue_title

        let oldSubj = ''
        let oldVal = ''
        let issueSubject = document.getElementById('issue_subject')
        let issueDescription = document.getElementById('issue_description')

        // for description
        if (issueDescription !== null) {
          let originalDescription = document.getElementById('original_description')
          if (issueDescription.value !== '' && shouldReplaced === 'false') {
            oldVal = issueDescription.value + '\n\n'
          }
          originalDescription.textContent = ns.escapeHTML(issueDescription.value)

          issueDescription.getAttribute('original_description', $('<div />').text(issueDescription.value).html())
          if (oldVal.replace(/(?:\r\n|\r|\n)/g, '').trim() !== obj.description.replace(/(?:\r\n|\r|\n)/g, '').trim()) {
            issueDescription.value = oldVal + obj.description
          }
        }

        let originalSubject = document.getElementById('original_subject')
        if (issueSubject.value !== '' && shouldReplaced === 'false') {
          oldSubj = issueSubject.value + ' '
        }
        originalSubject.textContent = ns.escapeHTML(issueSubject.value)

        if (confirmToReplace !== true && shouldReplaced === 'true' && (issueSubject.value !== '')) {
          if (oldSubj !== obj.issue_title) {
            let hideConfirmFlag = ns.hideOverwiteConfirm()
            if (hideConfirmFlag === false) {
              ns.confirmToReplace(targetUrl, confirmMsg, shouldReplaced, confirmation, generalTextYes, generalTextNo)
              return
            }
          }
        }

        issueSubject.setAttribute('original_title', $('<div />').text(issueSubject.value).html())
        if (oldSubj.trim() !== obj.issue_title.trim()) {
          issueSubject.value = oldSubj + obj.issue_title
        }

        try {
          if (CKEDITOR.instances.issue_description) {
            CKEDITOR.instances.issue_description.setData(oldVal + obj.description)
          }
        } catch (e) {
          // do nothing.
        }
        // show message just after default template loaded.
        if (confirmMsg) {
          ns.show_loaded_message(confirmMsg, issueSubject)
        }
        ns.addCheckList(obj)

        if (originalSubject.textContent.length > 0) {
          document.getElementById('revert_template').classList.remove('disabled')
        }

        if (obj.related_link !== '') {
          let relatedLink = document.getElementById('issue_template_related_link')

          relatedLink.setAttribute('href', obj.related_link)
          relatedLink.style.display = 'inline'
          relatedLink.textContent = obj.link_title
        } else {
          let relatedLink = document.getElementById('issue_template_related_link')
          relatedLink.style.display = 'none'
        }

        ns.builtin_fields(obj)
      })
    }
  },
  confirmToReplace: function (targetUrl, confirmMsg, shouldReplaced,
    confirmation, generalTextYes, generalTextNo) {
    let ns = this
    $('#issue_template_confirm_to_replace_dialog').dialog({
      modal: true,
      dialogClass: 'modal overflow_dialog',
      draggable: true,
      title: confirmation,
      width: 400,
      buttons: [
        {
          text: generalTextYes,
          click: function () {
            $(this).dialog('close')
            ns.load_template(targetUrl, confirmMsg, shouldReplaced, true, confirmation, generalTextYes, generalTextNo)
          }
        },
        {
          text: generalTextNo,
          click: function () {
            $(this).dialog('close')
          }
        }
      ]
    })
  },
  show_loaded_message: function (confirmMsg, target) {
    let templateStatusArea = $('#template_status-area')
    templateStatusArea.insertBefore(target)
    templateStatusArea.issueTemplate('flash_message', {
      text: confirmMsg,
      how: 'append'
    })
  },
  set_pulldown: function (tracker, targetUrl) {
    let allow_overwrite = $('#allow_overwrite_description').prop('checked')
    $.ajax({
      url: targetUrl,
      async: true,
      type: 'post',
      data: $.param({
        issue_tracker_id: tracker
      })
    }).done(function (data) {
      $('#issue_template').html(data)
      $('#allow_overwrite_description').attr('checked', allow_overwrite)
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
      $('span.checklist-item.new > span.icon.icon-add.save-new-by-button').click()
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
      let tmp = document.cookie.split('; ')
      for (let i = 0; i < tmp.length; i++) {
        let data = tmp[i].split('=')
        cookieArray[data[0]] = decodeURIComponent(data[1])
      }
    }
    let confirmationCookie = cookieArray['issue_template_confirm_to_replace_hide_dialog']
    if (confirmationCookie === undefined || parseInt(confirmationCookie) === 0) {
      return false
    }
    return true
  },
  // support built-in field update
  builtin_fields: function (template) {
    let builtinFieldsJson = template.builtin_fields_json
    if (builtinFieldsJson === undefined) return false
    Object.keys(builtinFieldsJson).forEach(function (key) {
      let value = builtinFieldsJson[key]
      let element = document.getElementById(key)
      if (element === null) {
        return
      }
      element.value = value
    })
  },
  updateTemplateSelect: (event) => {
    let link = event.target
    let optionId = link.getAttribute('data-issue-template-id')
    let optionSelector = '#issue_template > optgroup > option[value="' + optionId + '"]'
    if (link.classList.contains('template-global')) {
      optionSelector = optionSelector + '[class="global"]'
    }
    let targetOption = document.querySelector(optionSelector)
    targetOption['selected'] = true

    let changeEvent = new Event('change')
    document.getElementById('issue_template').dispatchEvent(changeEvent)
  }
};

// jQuery plugin for issue template
(function ($) {
  let methods = {
    init: function (options) {},
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
        // delay and fadeout
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
  $('#orphaned_template_link').on({
    'ajax:success': (function (_this) {
      return function (e, data) {
        $('#orphaned_templates').toggle()
        return $('#orphaned_templates').html(data)
      }
    })(this)
  })
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

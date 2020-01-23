/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// For namespace setting.
// var ISSUE_TEMPLATE = ISSUE_TEMPLATE || function () {}
function ISSUE_TEMPLATE(pulldownUrl, loadUrl, confirmMsg, shouldReplaced, confirmToReplace,
  confirmation, generalTextYes, generalTextNo, isTriggeredBy) {
  this.pulldownUrl = pulldownUrl
  this.loadUrl = loadUrl
  this.confirmMsg = confirmMsg
  this.shouldReplaced = shouldReplaced
  this.confirmToReplace = confirmToReplace
  this.confirmation = confirmation
  this.generalTextYes = generalTextYes
  this.generalTextNo = generalTextNo
  this.isTriggeredBy = isTriggeredBy
}

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
    fetch(url)
      .then((response) => {
        return response.text()
      })
      .then((data) => {
        document.getElementById('filtered_templates_list').innerHTML = data
        let titleElement = document.getElementById('issue_template_dialog_title')
        titleElement.textContent = title

        const templateElements = document.querySelectorAll('i.template-update-link')
        Array.from(templateElements).forEach(el => {
          el.addEventListener('click', (event) => {
            this.updateTemplateSelect(event)
          })
        })
      })
  },
  revertAppliedTemplate: function () {
    let issueSubject = document.getElementById('issue_subject')
    let oldSubject = document.getElementById('original_subject')

    let issueDescription = document.getElementById('issue_description')
    let oldDescription = document.getElementById('original_description')
    let templateNS = this

    issueSubject.value = templateNS.escapeHTML(oldSubject.textContent)

    if (issueDescription !== null) {
      issueDescription.value = templateNS.escapeHTML(oldDescription.textContent)
    }

    try {
      if (CKEDITOR.instances.issue_description) {
        CKEDITOR.instances.issue_description.setData(templateNS.escapeHTML(oldDescription.text()))
      }
    } catch (e) {
      // do nothing.
    }
    oldDescription.textContent = ''
    oldDescription.textContent = ''
    document.getElementById('revert_template').classList.add('disabled')
  },
  load_template: (confirm_flg) => {
    let confirmFlg = true
    if (confirm_flg != null) {
      confirmFlg = confirm_flg
    }

    let ns = templateNS
    let selectedTemplate = document.getElementById('issue_template')

    if (selectedTemplate.value === '') return

    let templateType = ''
    let selectedOption = selectedTemplate.options[selectedTemplate.selectedIndex]
    if (selectedOption.classList.contains('global')) {
      templateType = 'global'
    }

    fetch(ns.loadUrl,
      {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': ns.getCsrfToken()
        },
        body: JSON.stringify({
          template_id: selectedTemplate.value,
          template_type: templateType
        })
      })
      .then((response) => {
        return response.text()
      })
      .then((data) => {
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

        if (confirmFlg === true && ns.confirmToReplace === true && ns.shouldReplaced === 'true' && (issueSubject.value !== '')) {
          if (oldSubj !== obj.issue_title) {
            let hideConfirmFlag = ns.hideOverwiteConfirm()
            if (hideConfirmFlag === false) {
              return ns.confirmToReplaceMsg()
            }
          }
        }

        // for description
        if (issueDescription !== null) {
          let originalDescription = document.getElementById('original_description')
          if (issueDescription.value !== '' && ns.shouldReplaced === 'false') {
            oldVal = issueDescription.value + '\n\n'
          }

          originalDescription.textContent = issueDescription.value

          issueDescription.getAttribute('original_description', issueDescription.value)
          if (oldVal.replace(/(?:\r\n|\r|\n)/g, '').trim() !== obj.description.replace(/(?:\r\n|\r|\n)/g, '').trim()) {
            issueDescription.value = oldVal + obj.description
          }
        }

        let originalSubject = document.getElementById('original_subject')
        if (issueSubject.value !== '' && ns.shouldReplaced === 'false') {
          oldSubj = issueSubject.value + ' '
        }
        originalSubject.textContent = issueSubject.value

        issueSubject.setAttribute('original_title', issueSubject.value)
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
        if (ns.confirmMsg) {
          ns.show_loaded_message(ns.confirmMsg, issueSubject)
        }

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

        ns.addCheckList(obj)
        ns.builtin_fields(obj)
      })
  },
  confirmToReplaceMsg: () => {
    let ns = templateNS
    let dialog = document.getElementById('issue_template_confirm_to_replace_dialog')
    dialog.style.visibility = 'visible'
    dialog.classList.add('active')

    document.getElementById('overwrite_yes').addEventListener('click', () => {
      if (document.getElementById('issue_template_confirm_to_replace_hide_dialog').checked) {
        // NOTE: Use document.cookie because Redmine itself does not use jquery.cookie.js.
        document.cookie = 'issue_template_confirm_to_replace_hide_dialog=1'
      } else {
        document.cookie = 'issue_template_confirm_to_replace_hide_dialog=0'
      }
      dialog.classList.remove('active')
      ns.load_template(false)
    })

    document.getElementById('overwrite_no').addEventListener('click', () => {
      if (document.getElementById('issue_template_confirm_to_replace_hide_dialog').checked) {
        // NOTE: Use document.cookie because Redmine itself does not use jquery.cookie.js.
        document.cookie = 'issue_template_confirm_to_replace_hide_dialog=1'
      } else {
        document.cookie = 'issue_template_confirm_to_replace_hide_dialog=0'
      }
      dialog.classList.remove('active')
    })

    document.getElementById('issue_template_confirm_to_replace_dialog_cancel')
      .addEventListener('click', () => {
        dialog.classList.remove('active')
      })
  },
  show_loaded_message: (confirmMsg, target) => {
    // in app/views/issue_templates/_issue_select_form.html.erb
    let templateStatusArea = document.getElementById('template_status-area')
    if (templateStatusArea === null) return false
    if (document.querySelector('div.flash_message')) {
      document.querySelector('div.flash_message').remove()
    }

    let messageElement = document.createElement('div')
    messageElement.innerHTML = confirmMsg
    messageElement.classList.add('flash_message')
    messageElement.classList.add('fadeout')

    templateStatusArea.appendChild(messageElement)
  },
  getCsrfToken: () => {
    const metas = document.getElementsByTagName('meta')
    for (let meta of metas) {
      if (meta.getAttribute('name') === 'csrf-token') {
        return meta.getAttribute('content')
      }
    }
    return ''
  },
  set_pulldown: function (tracker) {
    let ns = this
    fetch(ns.pulldownUrl,
      {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': ns.getCsrfToken()
        },
        body: JSON.stringify({
          issue_tracker_id: tracker
        })
      })
      .then((response) => {
        return response.text()
      })
      .then((data) => {
        document.getElementById('issue_template').innerHTML = data
        let length = document.querySelectorAll('#issue_template > optgroup > option').length
        if (length < 1) {
          document.getElementById('template_area').style.display = 'none'
          if (ns.isTriggeredBy !== undefined && this.isTriggeredBy === 'issue_tracker_id') {
            if (document.querySelectorAll('#issue-form.new_issue').length > 0 && ns.should_replaced === true) {
              if (typeof templateNS !== 'undefined') {
                ns.eraseSubjectAndDescription()
              }
            }
          }
        } else {
          document.getElementById('template_area').style.display = 'inline'
        }
        let changeEvent = new Event('change')
        document.getElementById('issue_template').dispatchEvent(changeEvent)
      })
  },
  addCheckList: function (obj) {
    let list = obj.checklist
    if (list === undefined) return false
    let checklistForm = document.getElementById('checklist_form')
    if (!checklistForm) return

    // NOTE: If Checklist does not work fine, please confirm its version and the DOM element of
    // checklist input field exists.
    // If some difference, please report the issue or feedback to IssueTemplate's repository.
    try {
      for (let i = 0; i < list.length; i++) {
        let node = document.querySelector('span.checklist-item.new > span.checklist-edit-box > input.edit-box')
        if (node) {
          node.value = list[i]
          document.querySelector('span.checklist-item.new > span.icon.icon-add.checklist-new-only.save-new-by-button').click()
        }
      }
    } catch (e) {
      console.log(`NOTE: Checklist could not be applied due to this error. ${e.message} : ${e.message}`)
    }
  },
  escapeHTML: (val) => {
    const div = document.createElement('div')
    div.textContent = val
    return div.textContent
  },
  unescapeHTML: (val) => {
    const div = document.createElement('div')
    div.innerHTML = val
    return div.innerHTML
  },
  replaceCkeContent: () => {
    let element = document.getElementById('issue_description')
    return CKEDITOR.instances.issue_description.setData(element.value)
  },
  hideOverwiteConfirm: () => {
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
  builtin_fields: (template) => {
    let ns = templateNS
    let builtinFieldsJson = template.builtin_fields_json
    if (builtinFieldsJson === undefined) return false

    try {
      Object.keys(builtinFieldsJson).forEach(function (key) {
        let value = builtinFieldsJson[key]
        let element = document.getElementById(key)

        if (/issue_custom_field_values/.test(key)) {
          let name = key.replace(/(issue)_(\w+)_(\d+)/, '$1[$2][$3]')
          let elements = document.querySelectorAll('[name^="' + name + '"]')
          if (elements.length === 1) {
            element = elements[0]
          } else {
            return ns.updateFieldValues(elements, value)
          }
        }
        if (element === null) {
          return
        }
        ns.updateFieldValue(element, value)
      })
    } catch (e) {
      console.log(`NOTE: Builtin / custom fields could not be applied due to this error. ${e.message} : ${e.message}`)
    }
  },
  updateFieldValue: (element, value) => {
    // In case field is a select element, scans its option values and marked 'selected'.
    if (element.tagName.toLowerCase() === 'select') {
      let options = document.querySelectorAll('#' + element.id + ' option')
      let filteredOptions = Array.from(options).filter(option => option.text === value)
      if (filteredOptions.length > 0) {
        filteredOptions[0].selected = true
      }
    } else {
      element.value = value
    }
  },
  updateFieldValues: (elements, value) => {
    for (let i = 0; i < elements.length; i++) {
      let element = elements[i]
      if (element.tagName.toLowerCase() === 'select') {
        return templateNS.updateFieldValue(element, value)
      }
      if (element.value === value) {
        if (element.tagName.toLowerCase() === 'input') {
          element.checked = true
        } else {
          element.selected = true
        }
      }
    }
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
  },
  filterTemplate: (event) => {
    let cols = document.getElementsByClassName('template_data')
    let searchWord = event.target.value
    let reg = new RegExp(searchWord, 'gi')
    for (let i = 0; i < cols.length; i++) {
      let val = cols[i]
      if (val.textContent.match(reg)) {
        val.style.display = 'table-row'
      } else {
        val.style.display = 'none'
      }
    }
  },
  changeTemplatePlace: () => {
    if (document.querySelector('div.flash_message')) {
      document.querySelector('div.flash_message').remove()
    }
    const subjectParentNode = document.getElementById('issue_subject').parentNode
    subjectParentNode.parentNode.insertBefore(document.getElementById('template_area'), subjectParentNode)
  }
}

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

// --------- Add event listeners -------------- //
document.onreadystatechange = () => {
  if (document.readyState === 'complete') {
    let templateDisabledLink = document.querySelector('a.template-disabled-link')
    if (templateDisabledLink) {
      templateDisabledLink.addEventListener('click', (event) => {
        let title = event.target.title
        if (title.length && event.target.hasAttribute('disabled')) {
          event.preventDefault()
          window.alert(title)
          event.stopPropagation()
          return false
        }
      })
    }

    let templateHelps = document.querySelectorAll('a.template-help')
    for (let i = 0; i < templateHelps.length; i++) {
      let element = templateHelps[i]
      element.addEventListener('mouseenter', (event) => {
        let contentId = event.target.getAttribute('data-tooltip-content')
        if (contentId === null) return

        let target = event.target.getAttribute('data-tooltip-area')
        let obj = document.getElementById(target)
        if (obj) {
          obj.innerHTML = document.getElementById(contentId).innerHTML
          obj.style.display = 'inline'
        }
      })
      element.addEventListener('mouseleave', (event) => {
        let contentId = event.target.getAttribute('data-tooltip-content')
        if (contentId === null) return

        let target = event.target.getAttribute('data-tooltip-area')
        let obj = document.getElementById(target)
        if (obj) {
          obj.style.display = 'none'
        }
      })
    }

    let orphanedTemplateLink = document.getElementById('orphaned_template_link')
    if (orphanedTemplateLink) {
      orphanedTemplateLink.addEventListener('click', (event) => {
        const url = orphanedTemplateLink.getAttribute('data-url')
        fetch(url)
          .then((response) => {
            return response.text()
          })
          .then((data) => {
            let orphanedTemplate = document.getElementById('orphaned_templates')
            if (orphanedTemplate) {
              orphanedTemplate.innerHTML = data
            }
          })
      })
    }

    let collapsibleHelps = document.querySelectorAll('a.template-help.collapsible')
    if (collapsibleHelps) {
      for (let i = 0; i < collapsibleHelps.length; i++) {
        let element = collapsibleHelps[i]
        element.addEventListener('click', (event) => {
          let targetName = event.target.getAttribute('data-template-help-target')
          let target = document.getElementById(targetName)
          if (target) {
            let style = target.style.display
            target.style.display = (style === 'none' ? 'inline' : 'none')
          }
        })
      }
    }
  }
}

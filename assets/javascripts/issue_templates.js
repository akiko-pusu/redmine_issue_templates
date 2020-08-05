/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 *
 * Use '==' operator to evaluate null or undefined.
 */
/* global CKEDITOR, Element, Event */
'use strict'

function ISSUE_TEMPLATE (config) {
  this.pulldownUrl = config.pulldownUrl
  this.loadUrl = config.loadUrl
  this.confirmMsg = config.confirmMessage
  this.shouldReplaced = config.shouldReplaced
  this.generalTextYes = config.generalTextYes
  this.generalTextNo = config.generalTextNo
  this.isTriggeredBy = config.isTriggeredBy
}

ISSUE_TEMPLATE.prototype = {
  clearValue: (id) => {
    let target = document.getElementById(id)
    if (target == null) {
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
    window.fetch(url)
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
    let ns = this

    issueSubject.value = ns.escapeHTML(oldSubject.textContent)

    if (issueDescription != null) {
      issueDescription.value = ns.escapeHTML(oldDescription.textContent)
    }

    try {
      if (CKEDITOR.instances.issue_description) {
        CKEDITOR.instances.issue_description.setData(ns.escapeHTML(oldDescription.text()))
      }
    } catch (e) {
      // do nothing.
    }
    oldDescription.textContent = ''
    oldDescription.textContent = ''
    document.getElementById('revert_template').classList.add('disabled')
  },
  loadTemplate: function () {
    let selectedTemplate = document.getElementById('issue_template')
    let ns = this

    if (selectedTemplate.value === '') return

    let templateType = ''
    let selectedOption = selectedTemplate.options[selectedTemplate.selectedIndex]
    if (selectedOption.classList.contains('global')) {
      templateType = 'global'
    }

    window.fetch(ns.loadUrl,
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
        if (document.querySelector('#errorExplanation') && document.querySelector('#errorExplanation')[0]) {
          document.querySelector('#errorExplanation')
          return
        }

        // Returned JSON may have the key named 'global_template' or 'issue_template'
        let parsedData = JSON.parse(data)
        let templateKey = Object.keys(parsedData)[0]
        let obj = parsedData[templateKey]

        obj.description = (obj.description == null) ? '' : obj.description
        obj.issue_title = (obj.issue_title == null) ? '' : obj.issue_title

        let issueSubject = document.getElementById('issue_subject')
        let issueDescription = document.getElementById('issue_description')

        this.loadedTemplate = obj

        if (ns.shouldReplaced === 'true' && (issueDescription.value !== '' || issueSubject.value !== '')) {
          if (obj.description !== '' || obj.issue_title !== '') {
            let hideConfirmFlag = ns.hideOverwiteConfirm()
            if (hideConfirmFlag === false) {
              return ns.confirmToReplaceContent(obj)
            }
          }
        }
        ns.replaceTemplateValue(obj)
      })
  },
  replaceTemplateValue: function (obj) {
    let ns = this

    let oldSubj = ''
    let oldVal = ''
    let issueSubject = document.getElementById('issue_subject')
    let issueDescription = document.getElementById('issue_description')

    if (issueDescription != null) {
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
    if (ns.confirmMsg && ns.shouldReplaced) {
      ns.showLoadedMessage(issueDescription)
    }

    if (originalSubject.textContent.length > 0) {
      document.getElementById('revert_template').classList.remove('disabled')
    }

    ns.setRelatedLink(obj)
    ns.builtinFields(obj)
    ns.confirmToReplace = true
  },
  confirmToReplaceContent: function (obj) {
    let ns = this
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
      ns.replaceTemplateValue(obj)
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
  showLoadedMessage: function (target) {
    let ns = this
    // in app/views/issue_templates/_issue_select_form.html.erb
    let templateStatusArea = document.getElementById('template_status-area')
    if (templateStatusArea == null) return false
    if (document.querySelector('div.flash_message')) {
      document.querySelector('div.flash_message').remove()
    }

    let messageElement = document.createElement('div')
    messageElement.innerHTML = ns.confirmMsg
    messageElement.classList.add('flash_message')
    messageElement.classList.add('fadeout')

    templateStatusArea.appendChild(messageElement)
  },
  getCsrfToken: function () {
    const metas = document.getElementsByTagName('meta')
    for (let meta of metas) {
      if (meta.getAttribute('name') === 'csrf-token') {
        return meta.getAttribute('content')
      }
    }
    return ''
  },
  setPulldown: function (tracker) {
    let ns = this
    let params = { issue_tracker_id: tracker, is_triggered_by: ns.isTriggeredBy }
    let pullDownProject = document.getElementById('issue_project_id')
    if (pullDownProject) {
      params.issue_project_id = pullDownProject.value
    }

    window.fetch(ns.pulldownUrl,
      {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': ns.getCsrfToken()
        },
        body: JSON.stringify(params)
      })
      .then((response) => {
        return response.text()
      })
      .then((data) => {
        document.getElementById('issue_template').innerHTML = data
        let length = document.querySelectorAll('#issue_template > optgroup > option').length
        if (length < 1) {
          document.getElementById('template_area').style.display = 'none'
          if (ns.isTriggeredBy != null && this.isTriggeredBy === 'issue_tracker_id') {
            if (document.querySelectorAll('#issue-form.new_issue').length > 0 && ns.should_replaced === true) {
              if (typeof ns !== 'undefined') {
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
  setRelatedLink: function (obj) {
    let relatedLink = document.getElementById('issue_template_related_link')
    if (obj.related_link != null && obj.related_link !== '') {
      relatedLink.setAttribute('href', obj.related_link)
      relatedLink.style.display = 'inline'
      relatedLink.textContent = obj.link_title
    } else {
      relatedLink.style.display = 'none'
    }
  },
  escapeHTML: function (val) {
    const div = document.createElement('div')
    div.textContent = val
    return div.textContent
  },
  unescapeHTML: function (val) {
    const div = document.createElement('div')
    div.innerHTML = val
    return div.innerHTML
  },
  replaceCkeContent: function () {
    let element = document.getElementById('issue_description')
    return CKEDITOR.instances.issue_description.setData(element.value)
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
    if (confirmationCookie == null || parseInt(confirmationCookie) === 0) {
      return false
    }
    return true
  },
  // support built-in field update
  builtinFields: function (template) {
    let ns = this
    let builtinFieldsJson = template.builtin_fields_json
    if (builtinFieldsJson == null) return false

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

        if (/issue_watcher_user_ids/.test(key)) {
          return ns.checkSelectedWatchers(value)
        }

        if (element == null) {
          return
        }
        ns.updateFieldValue(element, value)
      })
    } catch (e) {
      console.log(`NOTE: Builtin / custom fields could not be applied due to this error. ${e.message} : ${e.message}`)
    }
  },
  updateFieldValue: function (element, value) {
    // In case field is a select element, scans its option values and marked 'selected'.
    if (element.tagName.toLowerCase() === 'select') {
      let values = []
      if (Array.isArray(value) === false) {
        values[0] = value
      } else {
        values = value
      }

      for (let i = 0; i < values.length; i++) {
        let options = document.querySelectorAll('#' + element.id + ' option')
        let filteredOptions = Array.from(options).filter(option => option.text === values[i])
        if (filteredOptions.length > 0) {
          filteredOptions[0].selected = true
        }
      }
    } else {
      element.value = value
    }
  },
  updateFieldValues: function (elements, value) {
    let ns = this
    for (let i = 0; i < elements.length; i++) {
      let element = elements[i]
      if (element.tagName.toLowerCase() === 'select') {
        return ns.updateFieldValue(element, value)
      }
      if (element.value === value) {
        if (element.tagName.toLowerCase() === 'input') {
          element.checked = true
        } else {
          element.selected = true
        }
      }
      // in case multiple value
      if (Array.isArray(value)) {
        if (element.tagName.toLowerCase() === 'input' && value.includes(element.value)) {
          element.checked = true
        }
      }
    }
  },
  updateTemplateSelect: function (event) {
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
  checkSelectedWatchers: function (values) {
    let targets = document.querySelectorAll('input[name="issue[watcher_user_ids][]"]')
    for (let i = 0; i < targets.length; i++) {
      let target = targets[i]
      if (values.includes(target.value)) {
        target.checked = true
      }
    }
  },
  filterTemplate: function (event) {
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
  changeTemplatePlace: function () {
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
    } while (el != null && el.nodeType === 1)
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
        if (contentId == null) return

        let target = event.target.getAttribute('data-tooltip-area')
        let obj = document.getElementById(target)
        if (obj) {
          obj.innerHTML = document.getElementById(contentId).innerHTML
          obj.style.display = 'inline'
        }
      })
      element.addEventListener('mouseleave', (event) => {
        let contentId = event.target.getAttribute('data-tooltip-content')
        if (contentId == null) return

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
        window.fetch(url)
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

// ------- fot NoteTemplate

function NOTE_TEMPLATE (config) {
  this.baseElementId = config.baseElementId
  this.baseTemplateListUrl = config.baseTemplateListUrl
  this.baseTrackerId = config.baseTrackerId
  this.baseProjectId = config.baseProjectId
  this.loadNoteTemplateUrl = config.loadNoteTemplateUrl
}

NOTE_TEMPLATE.prototype = {
  setNoteDescription: function (target, value, container) {
    let element = document.getElementById(target)
    if (element.value.length === 0) {
      element.value = value
    } else {
      element.value += '\n\n' + value
    }
    element.focus()
    container.style.display = 'none'

    try {
      if (CKEDITOR.instances.issue_notes) {
        CKEDITOR.instances.issue_notes.setData(value)
        CKEDITOR.instances.issue_notes.focus()
      }
    } catch (e) {
      // do nothing.
    }
  },
  applyNoteTemplate: function (targetElement) {
    let ns = this
    let templateId = targetElement.dataset.noteTemplateId
    let projectId = document.getElementById('issue_project_id')
    let loadUrl = ns.loadNoteTemplateUrl

    let JSONdata = {
      note_template: { note_template_id: templateId }
    }

    if (targetElement.classList.contains('template-global')) {
      JSONdata.note_template.template_type = 'global'
      JSONdata.note_template.project_id = ns.baseProjectId
      if (projectId && projectId.value) {
        JSONdata.note_template.project_id = projectId.value
      }
    }

    let token = document.querySelector('#issue-form input[name="authenticity_token"]')
    let req = new window.XMLHttpRequest()
    req.onreadystatechange = function () {
      let container = targetElement.closest('div.overlay')
      let target = container.id.replace('template_', '')
      target = target.replace('_dialog', '')
      if (req.readyState === 4) {
        if (req.status === 200 || req.status === 304) {
          let value = JSON.parse(req.responseText)
          ns.setNoteDescription(target, value.note_template.description, container)
        }
      }
    }
    req.open('POST', loadUrl, true)
    if (token) {
      req.setRequestHeader('X-CSRF-Token', token.value)
    }
    req.setRequestHeader('Content-Type', 'application/json')
    req.send(JSON.stringify(JSONdata))
  },
  changeNoteTemplateList: function (elementId) {
    let ns = this
    let token = document.querySelectorAll('#issue-form input[name="authenticity_token"]')

    let projectId = document.getElementById('issue_project_id')
    let trackerId = document.getElementById('issue_tracker_id')
    let templateListUrl = ns.baseTemplateListUrl
    if (trackerId != null && projectId != null) {
      templateListUrl += '?tracker_id=' + trackerId.value
      templateListUrl += '&project_id=' + projectId.value
    } else {
      templateListUrl += '?tracker_id=' + ns.baseTrackerId + '&project_id=' + ns.baseProjectId
    }

    let req = new window.XMLHttpRequest()
    req.onreadystatechange = function () {
      if (req.readyState === 4) {
        if (req.status === 200 || req.status === 304) {
          let value = req.responseText
          // replace here!
          let dialog = document.getElementById(`${elementId}_dialog`)
          let target = document.querySelector(`#${elementId}_dialog .popup .filtered_templates_list`)
          target.innerHTML = value
          dialog.style = 'display: block;'
        }
      }
    }
    req.open('GET', templateListUrl, true)
    if (token) {
      req.setRequestHeader('X-CSRF-Token', token.value)
    }
    req.send()
  }
}

const removeCheckList = (obj) => {
  let target = obj.closest('li')
  target.remove()
}

const addCheckList = () => {
  let checkListInputText = document.getElementById('checklist_text')
  let text = checkListInputText.value
  if (text === '') return false

  let checkListItems = document.getElementsByClassName('checklist-item')
  // NOTE: some, find, every and forEach method scan all the element and not exit this function via return.
  for (let i = 0; i < checkListItems.length; i++) {
    let elem = checkListItems[i]
    if (text === elem.value) {
      return
    }
  }

  addCheckListItem(text)
  checkListInputText.value = ''
}

const addCheckListItem = (value) => {
  let li = document.createElement('li')
  let span = document.createElement('span')
  span.classList.add('text')

  let checkListText = document.createTextNode(value)
  span.appendChild(checkListText);

  let hidden = document.createElement('input')
  hidden.classList.add('checklist-item')
  hidden.value = value
  hidden.setAttribute('type', 'hidden')
  hidden.setAttribute('id', template_type + '_checklist')
  hidden.setAttribute('name', template_type + '[checklists][]')

  li.appendChild(hidden)

  let removeLink = document.createElement('i')
  removeLink.classList.add('icon', 'icon-del')
  span.appendChild(removeLink)

  li.appendChild(span)

  let checklist = document.querySelector('ul.checklist')
  checklist.appendChild(li)

  removeLink.addEventListener('click', (event) => {
    removeCheckList(event.target)
  }, false)
}

const copyJson = document.getElementById('paste-json')
if (copyJson) {
  copyJson.addEventListener('click', (event) => {
    const data = document.getElementById('builtin_fields_data_via_vue')
    if (data) {
      const text = data.innerText
      let jsonObj = JSON.parse(text)
      let convertObj = {}
      jsonObj.forEach(item => { convertObj[item.title] = item.value })
      document.getElementById(template_type + '_builtin_fields').value = JSON.stringify(convertObj)
    }
  })
}

// This JS is used only when create / edit template. (Using Vue.js)
'use strict'
const vm = new Vue({
  el: '#json_generator',
  data: {
    items: [],
    customFields: {},
    newItemTitle: '',
    newItemValue: '',
    api_builtin_fields: {},
    api_custom_fields: {},
    customFieldUrl: ''
  },
  methods: {
    addField: function (newFieldName, newFieldValue) {
      if (newFieldName === '' || newFieldValue === '') {
        return
      }
      this.items.push({
        title: newFieldName,
        value: newFieldValue
      })
      this.newFieldName = ''
      this.newFieldValue = ''
    },
    deleteField: function (target) {
      this.items = this.items.filter(function (item) {
        return item !== target
      })
    },
    loadField: function () {
      this.api_builtin_fields = base_builtin_fields
      this.api_custom_fields = base_custom_fields
      this.items = []
      if (this.api_builtin_fields) {
        for (const [key, value] of Object.entries(this.api_builtin_fields)) {
          this.items.push({
            title: key,
            value: value
          })
        }
      }
      // { "issue_priority_id":"Priority", "issue_start_date":"Start date" }
      if (this.api_custom_fields) {
        for (const [key, value] of Object.entries(this.api_custom_fields)) {

          this.customFields[key] = value
        }
      }
    },
    updateSelectableField: function () {
      let tmpFields = {}
      if (this.api_custom_fields) {
        for (const [key, value] of Object.entries(this.api_custom_fields)) {
          tmpFields[key] = value
        }
      }
      this.customFields = tmpFields
    },
    fieldFormat: function () {
      const fields = this.customFields
      const title = this.newItemTitle
      if (fields[title] && fields[title].field_format) {
        const format = fields[title].field_format
        if (format === 'int' || format === 'date' || format === 'ratio' ||
            format === 'list' || format === 'bool' || format === 'string') {
          return fields[title].field_format
        }
      }
      return 'text'
    },
    possibleValues: function () {
      const fields = this.customFields
      const title = this.newItemTitle
      return fields[title].possible_values
    }
  },
  mounted: function () {
    const trackerPulldown = document.getElementById(trackerPulldownId)
    if (trackerPulldown) {
      if (trackerPulldown.value === '') {
        this.$el.style.display = 'none'
      }
      trackerPulldown.addEventListener('change', event => {
        if (event.target.value === '') {
          this.$el.style.display = 'none'
          return
        }
        this.$el.style.display = 'block'
        const trackerId = event.target.value
        let url = baseUrl + '?tracker_id=' + trackerId + '&template_id=' + templateId
        if (typeof projectId !== 'undefined') {
          url += '&project_id=' + projectId
        }
        window.fetch(url)
          .then((response) => {
            return response.text()
          })
          .then((data) => {
            let obj = JSON.parse(data)
            this.api_custom_fields = obj.custom_fields
            this.updateSelectableField()
          })
      })
    }
    this.loadField()
  },
  computed: {
    // not yet
  },
  watch: {
    newItemTitle: function (val) {
      if (typeof relativeUrlRoot === 'undefined') {
        this.customFieldUrl = ''
        return
      }

      let field = this.customFields[val]
      if (field == null || field.type != 'IssueCustomField') {
        this.customFieldUrl = ''
        return
      }
      this.customFieldUrl = relativeUrlRoot + '/custom_fields/' + field.id + '/edit'
    }
  }
})

// Apply post data.
const copyJson = document.getElementById('paste-json')
if (copyJson) {
  copyJson.addEventListener('click', (event) => {
    const data = document.getElementById('builtin_fields_data_via_vue')
    if (data) {
      const text = data.innerText
      let jsonObj = JSON.parse(text)
      let convertObj = {}
      jsonObj.forEach(item => {
        let value = item.value
        if (item.title === 'issue_watcher_user_ids') {
          value = item.value.map(user => {
            let idx = user.lastIndexOf(':')
            return user.substring(idx + 1)
          })
        }
        convertObj[item.title] = value
      })
      document.getElementById(templateType + '_builtin_fields').value = JSON.stringify(convertObj)
    }
  })
}

// This JS is used only when create / edit template. (Using Vue.js)
const vm = new Vue({
  el: '#json_generator',
  data: {
    items: [],
    customFields: {},
    newItemTitle: '',
    newItemValue: '',
    api_builtin_fields: {},
    api_custom_fields: {}
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
      });
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
        if (format == 'date' || format == 'ratio' || format == 'list' || format == 'bool') {
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
    const tracker_pulldown = document.getElementById(tracker_pulldown_id)
    if (tracker_pulldown) {
      if (tracker_pulldown.value === '') {
        this.$el.style.display = 'none'
      }
      tracker_pulldown.addEventListener('change', event => {
        if (event.target.value === '') {
          this.$el.style.display = 'none'
          return
        }
        this.$el.style.display = 'block'
        const tracker_id = event.target.value
        let url = baseUrl + '?tracker_id=' + tracker_id + '&template_id=' + template_id
        fetch(url)
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
  }
})

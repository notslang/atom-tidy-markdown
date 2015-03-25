TidyMarkdown = require './tidy-markdown'

module.exports =
  configDefaults:
    runOnSave: true
    ensureFirstHeaderIsH1: true

  activate: ->
    @tidyMarkdown = new TidyMarkdown()

  deactivate: ->
    @tidyMarkdown?.destroy()
    @tidyMarkdown = null

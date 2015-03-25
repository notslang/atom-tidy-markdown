{Subscriber} = require 'emissary'
tidyMarkdown = require 'tidy-markdown'

class TidyMarkdown
  Subscriber.includeInto(this)

  constructor: ->
    @subscribe atom.workspace.eachEditor (editor) =>
      @handleEvents(editor)

    atom.commands.add 'atom-text-editor',
      'tidy-markdown:run': =>
        if editor = atom.workspace.getActiveEditor()
          @run(editor, editor.getGrammar().scopeName)

  destroy: ->
    @unsubscribe()

  handleEvents: (editor) ->
    buffer = editor.getBuffer()
    bufferSavedSubscription = @subscribe buffer, 'will-be-saved', =>
      buffer.transact =>
        if atom.config.get('tidy-markdown.runOnSave')
          @run(editor, editor.getGrammar().scopeName)

    @subscribe editor, 'destroyed', =>
      bufferSavedSubscription.off()
      @unsubscribe(editor)

    @subscribe buffer, 'destroyed', =>
      @unsubscribe(buffer)

  run: (editor, grammarScopeName) ->
    if grammarScopeName isnt 'source.gfm' then return
    buffer = editor.getBuffer()
    text = buffer.getText()
    fixedText = tidyMarkdown(
      text
      ensureFirstHeaderIsH1: atom.config.get(
        'tidy-markdown.ensureFirstHeaderIsH1'
      )
    )
    if text isnt fixedText
      buffer.setTextViaDiff(fixedText)

module.exports = TidyMarkdown

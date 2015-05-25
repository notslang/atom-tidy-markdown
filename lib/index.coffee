{CompositeDisposable} = require 'atom'
tidyMarkdown = require 'tidy-markdown'

module.exports =
  subscriptions: null

  config:
    runOnSave:
      type: 'boolean'
      default: true
    ensureFirstHeaderIsH1:
      type: 'boolean'
      default: true

  activate: ->
    @subscriptions = new CompositeDisposable()
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      @handleEvents(editor)
    @subscriptions.add atom.commands.add 'atom-workspace',
      'tidy-markdown:run': => @run()

  destroy: ->
    @subscriptions.dispose()

  handleEvents: (editor) ->
    buffer = editor.getBuffer()
    bufferSavedSubscription = buffer.onWillSave =>
      buffer.transact =>
        if atom.config.get('tidy-markdown.runOnSave')
          @run(editor, editor.getGrammar().scopeName)

    editorDestroyedSubscription = editor.onDidDestroy ->
      bufferSavedSubscription.dispose()
      editorDestroyedSubscription.dispose()

    bufferDestroyedSubscription = buffer.onDidDestroy ->
      bufferDestroyedSubscription.dispose()
      bufferSavedSubscription.dispose()

    @subscriptions.add(bufferSavedSubscription)
    @subscriptions.add(editorDestroyedSubscription)
    @subscriptions.add(bufferDestroyedSubscription)

  run: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor.getGrammar().scopeName isnt 'source.gfm' then return
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

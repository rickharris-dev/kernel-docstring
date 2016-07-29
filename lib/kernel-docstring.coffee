{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'kernel-docstring:convert': => @convert()

  deactivate: ->
    @subscriptions.dispose()

  convert: ->
    if editor = atom.workspace.getActiveTextEditor()
      selection = editor.getSelectedText()
      if (/^([\w]+[ ](?=[\*\w])[*]*\w+(?=[(])\([\w*, ]+\))/.test(selection))
        function_name = selection.match(/\w+(?=[(])/)
        parameters = selection.match(/\w+(?=[)]|[,])/g)

        editor.insertText("/**\n")
        if function_name.length
          for func in function_name
            editor.insertText(" * #{func} -\n")

        if parameters.length
          for param in parameters
            editor.insertText(" * @#{param}:\n")
        editor.insertText(" * Description:\n */\n#{selection}")
      else
        console.log("Error: Function is formatted incorrectly. Check with Betty.")

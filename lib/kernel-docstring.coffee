{CompositeDisposable} = require 'atom'

module.exports =
    subscriptions: null

    activate: ->
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace',
            'kernel-docstring:convert': => @convert()

    deactivate: ->
        @subscriptions.dispose()

    docstring: (func_match) ->
        new_value = ['/**']
        func_match = func_match.split '('.split ' '
        console.log func_match

    convert: ->
        docstring = (func_match) ->
            name_pattern = ///
                \w+     # Finds words of any length
                (?=[(]) # Finds start of params section
                ///

            return_pattern = ///
                \w+         # Return value
                (?=\s\w+\() # Before function name
                ///

            params_pattern = ///
                \w+                 # Param name
                (?=\s?[)]|\s?[,])   # Checks for , or ) at end of param
                ///g

            new_value = ['/**']
            line_start = ' * '
            end_string = ' */'
            name = func_match.match name_pattern
            return_type = func_match.match return_pattern
            console.log return_type
            params = func_match.match params_pattern

            new_value.push [line_start, name, ' -'].join ''
            for param in params
                new_value.push [line_start, '@', param, ':'].join ''
            new_value.push [line_start, 'Description:'].join ''
            if return_type[0] != 'void'
                new_value.push [line_start, 'Return:'].join ''
            new_value.push end_string, func_match
            return new_value.join '\n'

        function_pattern = /// ^
            (                         # Start capture group
            (?:static\s|inline\s)?    # Accounts for static or inline at front
            [\w]+[\ ]                 # Checks for return value
            [*]*                      # Accounts for pointer return value
            \w+                       # Function name
            \([\w*,\ ]+\)             # Argument range between ( and )
            )                         # End capture group
            (?![;])                   # Confirms it is not a prototype
            $ ///
        if editor = atom.workspace.getActiveTextEditor()
            editor.selectAll()
            selection = editor.getSelectedText().split '\n'
            i = 0
            while i < selection.length
                if selection[i].match function_pattern
                    if selection[i - 1] != ' */'
                        selection[i] = docstring(selection[i])
                        console.log selection[i]
                i++
            editor.insertText(selection.join '\n')

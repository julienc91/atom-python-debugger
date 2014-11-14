PythonDebuggerView = require './python-debugger-view'

module.exports =
  pythonDebuggerView: null

  activate: ->
    atom.workspaceView.command "python-debugger:insert", => @insert()
    atom.workspaceView.command "python-debugger:remove", => @remove()

  insert: ->
    IMPORT_STATEMENT = "import ipdb\n"
    editor = atom.workspace.activePaneItem
    cursors = editor.getCursors()
    saved_positions = []

    for cursor in cursors
      cursor.moveToFirstCharacterOfLine()
      saved_positions.push cursor.getBufferPosition()

    editor.insertText(
      "ipdb.set_trace()  ######### Break Point ###########\n",
      options={
        "autoIndentNewline": true
        "autoIndent": true
      }
    )

    editor.moveCursorToTop()
    insert_position = editor.getCursorBufferPosition()
    editor.moveCursorToBeginningOfLine()
    editor.selectToEndOfLine()
    line = editor.getSelectedText()

    # skip comments (and Python headers), "from __future__" imports and empty lines
    while (line.startsWith "#") or (line.startsWith "from __future__") or (not line)
      editor.moveCursorToBeginningOfLine()
      editor.moveCursorDown()
      editor.selectToEndOfLine()
      if line
        insert_position = editor.getCursorBufferPosition()
      line = editor.getSelectedText()

    editor.setCursorBufferPosition(insert_position)

    if not (IMPORT_STATEMENT.startsWith line)
      editor.moveCursorToBeginningOfLine()
      editor.insertText(IMPORT_STATEMENT)

    for cursor, index in cursors
      cursor.setBufferPosition(saved_positions[index])

  remove: ->
    editor = atom.workspace.activePaneItem
    console.log('removing all imports')
    matches = []
    editor.buffer.backwardsScan /^\s*ipdb\.|^import ipdb/gm, (match) -> matches.push(match)
    for match in matches
      console.log(match)
      editor.setCursorScreenPosition([match.range.start.row, 1])
      editor.deleteLine()

KernelDocString = require '../lib/kernel-docstring'

describe "KernelDocString", () ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace);
    activationPromise = atom.packages.activatePackage('kernel-docstring');

    waitsForPromise ->
      atom.workspace.open()

  it 'uses the function prototype to build the docstring structure', ->
    editor = atom.workspace.getActiveTextEditor()
    editor.insertText("int main(int **test0, char **test1, char *test2)")
    editor.selectAll()
    changeHandler = jasmine.createSpy('changeHandler')
    editor.onDidChange(changeHandler)

    atom.commands.dispatch workspaceElement, 'kernel-docstring:convert'

    waitsForPromise ->
      activationPromise

    waitsFor ->
      changeHandler.callCount > 0

    runs ->
      test_string = '/**\n * main -\n * @test0:\n * @test1:\n * @test2:\n * Description:\n */\nint main(int **test0, char **test1, char *test2)'
      expect(editor.getText()).toEqual test_string

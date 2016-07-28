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
      expect(editor.getText()).toEqual """
/**
 * main -
 * @test0:
 * @test1:
 * @test2:
 * Description:
 */
int main(int **test0, char **test1, char *test2)
"""

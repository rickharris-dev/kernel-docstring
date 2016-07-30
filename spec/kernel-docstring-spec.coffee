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
  it 'updates all functions in the file and ignores prototypes', ->
    editor = atom.workspace.getActiveTextEditor()
    editor.insertText("""int test(char *test);

void ntree_free(NTree *tree)
{

}

/**
 * ntree_insert -
 * @tree:
 * @parents:
 * @data:
 * Description:
 */
int ntree_insert(NTree **tree, char **parents, char *data)
{

}

int path_exists(NTree *tree, char **path)
{

}""")
    editor.selectAll()
    changeHandler = jasmine.createSpy('changeHandler')
    editor.onDidChange(changeHandler)

    atom.commands.dispatch workspaceElement, 'kernel-docstring:convert'

    waitsForPromise ->
      activationPromise

    waitsFor ->
      changeHandler.callCount > 0

    runs ->
      test_string = 'int test(char *test);\n\n/**\n * ntree_free -\n * @tree:\n * Description:\n */\nvoid ntree_free(NTree *tree)\n{\n\n}\n\n/**\n * ntree_insert -\n * @tree:\n * @parents:\n * @data:\n * Description:\n */\nint ntree_insert(NTree **tree, char **parents, char *data)\n{\n\n}\n\n/**\n * path_exists -\n * @tree:\n * @path:\n * Description:\n */\nint path_exists(NTree *tree, char **path)\n{\n\n}'
      expect(editor.getText()).toEqual test_string

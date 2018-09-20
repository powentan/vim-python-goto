if !has('python')
    finish
endif

python << EOF
import imp
import sys
import os
# https://stackoverflow.com/questions/5795562/version-of-imp-find-module-that-works-on-dotted-modules 
def find_dotted_module(name, path=None):
    '''
    Example: find_dotted_module('mypackage.myfile')

    Background: imp.find_module() does not handle hierarchical module names (names containing dots).

    Important: No code of the module gets executed. The module does not get loaded (on purpose)
    ImportError gets raised if the module can't be found.

    Use case: Test discovery without loading (otherwise coverage does not see the lines which are executed
              at import time)
    '''

    for x in name.split('.'):
        if x == "":
            continue

        if path is not None:
            path = [path]
        try:
            file, path, descr = imp.find_module(x, path)
        except:
            path = None
            break
    return path
    

def find_module(name, file_path):
    path = None
    search_path = ['./', file_path]
    search_path.extend(sys.path)
    # vim.command("echo 'search_path = %s'" % search_path)
    for sys_path in search_path:
        # vim.command("echo 'sys_path = %s'" % sys_path)
        path = find_dotted_module(name, sys_path)
        # vim.command("echo 'path = %s'" % path)
        if path is not None:
            break

    return path
EOF

function! python#goto#GotoModule(module)
echo a:module
let s:path = expand('%:p:h')
python << EOF
import vim
module_path = find_module(vim.eval('a:module'), vim.eval('s:path'))
# module_path = __import__(vim.eval('a:module'), vim.eval('s:path'))
vim.command("let module_path = '%s'" % module_path)
EOF
echo module_path
if isdirectory(module_path)
    let module_path = module_path . '/__init__.py'
endif
" return module_path
exec 'silent edit! ' . module_path
endfunction

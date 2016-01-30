" checkpoint.vim - rapidly save, restore, and diff files being worked on
" Author: Kevin Johnson <vadskye@gmail.com>

" if vi compatible mode is set, don't load
if &cp || exists('g:loaded_checkpoint')
    finish
endif
let g:loaded_checkpoint = 1

" Set a variable's default value, but don't override any existing value
" This allows user settings in the vimrc to work
function! s:init_variable(variable_name, value)
    if !exists('g:checkpoint_' . a:variable_name)
        if type(a:value) == type("")
            execute 'let g:checkpoint_' . a:variable_name . ' = "' . a:value . '"'
        elseif type(a:value) == type(0)
                \ || type(a:value) == type([])
                \ || type(a:value) == type({})
            execute 'let g:checkpoint_' . a:variable_name . ' = '. string(a:value)
        else
            echoerr "Unable to recognize type '" . type(a:value) .
                \ "' of '" . string(a:value) .
                \ "' for variable '" . a:variable_name . "'"
        endif
    endif
endfunction

function! s:set_default_options()
    let options = {
        \ 'directory': $HOME . "/.vim/checkpoints",
        \ 'path_separator': has('win32')
            \ ? (&shellslash ? '[/:]' : '[\\:]')
            \ : '/',
    \ }

    for variable_name in keys(options)
        call s:init_variable(variable_name, options[variable_name])
    endfor
endfunction
call s:set_default_options()

" Make sure that all options which should be set by the user have valid values
function! s:validate_options()
    let valid_values = {
    \ }

    for [variable_name, values] in items(valid_values)
        let variable_value = get(g:, 'checkpoint_' . variable_name)
        if ! checkpoint#util_in_list(variable_value, values)
            echohl WarningMsg
            echomsg "checkpoint: Variable g:checkpoint_" . variable_name . " has invalid value '" . variable_value . "'"
            echohl none
        endif
    endfor

    " make sure the checkpoint directory exists
    if !isdirectory(g:checkpoint_directory)
        call mkdir(g:checkpoint_directory, 'p')
    endif
endfunction
call s:validate_options()


command! Checkpoint call checkpoint#save_checkpoint()
command! SaveCheckpoint call checkpoint#save_checkpoint()
command! LoadCheckpoint call checkpoint#load_checkpoint()
command! DiffCheckpoint call checkpoint#diff_checkpoint()

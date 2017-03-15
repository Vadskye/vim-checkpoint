if &cp || exists('g:loaded_checkpoint_auto')
    finish
endif

function! checkpoint#save_checkpoint() abort
    let checkpoint_file_path = s:get_checkpoint_file_path()
    execute "keepalt write! " . checkpoint_file_path
endfunction

function! checkpoint#load_checkpoint() abort
    let original_window_top = line('w0') + &scrolloff
    let original_location = [line('.'), col('.')]
    let original_buffer_end = line('$')
    let checkpoint_file_path = s:get_checkpoint_file_path()

    try
        " read the saved checkpoint into the buffer
        silent execute "keepalt " . original_buffer_end . "read " . checkpoint_file_path
        " remove the original buffer text
        silent execute "1," . original_buffer_end . "delete"
        " restore the original window view
        execute "normal! " . original_window_top . "z\<CR>"
        call cursor(original_location)
    catch
        echoerr "Error restoring checkpoint: " . v:exception
    endtry
endfunction

function! checkpoint#diff_checkpoint() abort
    let checkpoint_file_path = s:get_checkpoint_file_path()
    execute "diffsplit " . checkpoint_file_path
    " discourage modification of the checkpoint directly
    setlocal nomodifiable
    " automatically exit diff mode after exiting the checkpoint buffer
    autocmd QuitPre <buffer> windo diffoff
endfunction

function! s:get_checkpoint_file_path() abort
    return g:checkpoint_directory . '/' . substitute(
        \ expand('%:p'),
        \ '\v' . g:checkpoint_path_separator,
        \ '\\%',
        \ 'g'
    \ )
endfunction

let g:loaded_checkpoint_auto = 1

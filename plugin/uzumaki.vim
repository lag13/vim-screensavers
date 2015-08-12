function! InitializeUzumaki()
    let g:top_limit = 1
    let g:bottom_limit = &lines
    let g:left_limit = 0
    let g:right_limit = &columns
    let g:dir = 'l'
    let g:char = '#'

    for y in range(1, &lines-1)
        call setline(y, repeat(' ', &columns))
    endfor
endfunction

function! UpdateSpiral()
    call AlterDrawing()
    execute "normal! r".g:char
    call AdvanceCursor()
    redraw
endfunction

function! AlterDrawing()
    if g:left_limit >= g:right_limit || g:top_limit >= g:bottom_limit
        let g:top_limit = 1
        let g:bottom_limit = &lines
        let g:left_limit = 0
        let g:right_limit = &columns
        let g:dir = 'l'
        if g:char ==# '#'
            let g:char = ' '
        else
            let g:char = '#'
        endif
        call cursor(1, 1)
    endif
endfunction

function! AdvanceCursor()
    let row = line('.')
    let col = col('.')
    if row == g:top_limit && col == g:right_limit
        let g:dir = 'j'
        let g:bottom_limit = g:bottom_limit - 1
    elseif row == g:bottom_limit && col == g:right_limit
        let g:dir = 'h'
        let g:left_limit = g:left_limit + 2
    elseif row == g:bottom_limit && col == g:left_limit
        let g:dir = 'k'
        let g:top_limit = g:top_limit + 1
    elseif row == g:top_limit && col == g:left_limit
        let g:dir = 'l'
        let g:right_limit = g:right_limit - 2
    endif
    execute "normal! ".g:dir
endfunction

function! UzumakiLoop()
    while 1
        " Quit if any character is pressed
        if getchar(0)
            break
        endif
        call UpdateSpiral()
        sleep 10m
    endwhile
endfunction

function! Uzumaki()
    call InitializeScreenSaver()
    call InitializeUzumaki()
    call UzumakiLoop()
    call QuitScreenSaver()
endfunction

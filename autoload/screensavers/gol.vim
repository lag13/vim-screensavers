function! s:getNumActiveBits(num)
    let n = a:num
    let c = 0
    while n
        if n % 2
            let c += 1
        endif
        let n = n / 2
    endwhile
    return c
endfunction

function! s:calculateLookupTableEntry(n_state)
    let cell_state = a:n_state / 16 % 2
    let living_count = s:getNumActiveBits(a:n_state)
    if living_count == 3
        return 1
    elseif living_count == 4
        return cell_state
    else
        return 0
    endif
endfunction

function! s:initializeGameOfLife()
    " Add 2 for the two rows of padding
    let g:width = &columns + 2
    " Subtract 1 for the command line window
    let g:height = &lines - 1 + 2
    let g:update_buffer = []
    let g:board = []
    let g:lookup_table = []
    let s:syntax_highlighting = get(g:, 'syntax_highlighting', 0)
    if s:syntax_highlighting
        let s:cell_char = "\t"
    else
        let s:cell_char = "#"
    endif

    " Highlight the living cells
    if s:syntax_highlighting
        highlight LivingCell term=reverse cterm=reverse gui=reverse
        execute "syntax match LivingCell '".s:cell_char."'"
    endif

    " Create an empty board
    for y in range(0, g:height-1)
        call add(g:board, repeat([0], g:width))
    endfor

    call screensaver#seedRNG(localtime())
    " Be sure to only initialize the non-padding areas
    for y in range(1, g:height-2)
        for x in range(1, g:width-2)
            let g:board[y][x] = screensaver#getRand() % 2
        endfor
    endfor
    for i in range(0, 511)
        call add(g:lookup_table, s:calculateLookupTableEntry(i))
    endfor
endfunction

function! s:displayBoard()
    " Be sure to only display the non-padded part of the data structure
    for y in range(1, g:height-2)
        let line = ''
        for x in range(1, g:width-2)
            let cell = ' '
            if g:board[y][x]
                let cell = s:cell_char
            endif
            let line = line . cell
        endfor
        call setline(y, line)
    endfor
    redraw
endfunction

function! s:updateBoard()
    " TODO: See if doing a copy on each row would be more efficient or not
    let g:update_buffer = deepcopy(g:board)
    " Be sure to only update the non-padded part of the data structure
    for y in range(1, g:height-2)
        let n_state = 0
        if g:update_buffer[y-1][0] | let n_state += 32 | endif
        if g:update_buffer[y-1][1] | let n_state += 4  | endif
        if g:update_buffer[y  ][0] | let n_state += 16 | endif
        if g:update_buffer[y  ][1] | let n_state += 2  | endif
        if g:update_buffer[y+1][0] | let n_state += 8  | endif
        if g:update_buffer[y+1][1] | let n_state += 1  | endif
        for x in range(1, g:width-2)
            let n_state = n_state % 64 * 8
            if g:update_buffer[y-1][x+1] | let n_state += 4 | endif
            if g:update_buffer[y  ][x+1] | let n_state += 2 | endif
            if g:update_buffer[y+1][x+1] | let n_state += 1 | endif
            let g:board[y][x] = g:lookup_table[n_state]
        endfor
    endfor
endfunction

function! s:gameLoop()
    while 1
        " Quit if any character is pressed
        if getchar(0)
            break
        endif
        call s:displayBoard()
        call s:updateBoard()
    endwhile
endfunction

function! screensavers#gol#gameOfLife()
    call screensaver#initializeScreenSaver()
    call s:initializeGameOfLife()
    call s:gameLoop()
    call screensaver#quitScreenSaver()
endfunction

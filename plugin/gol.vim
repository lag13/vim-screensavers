function! SeedRNG()
    " I mod it by 44488 because 48271 * 44488 is the largest number that is
    " still less than 2147483647 (the largest number possible). If we go over
    " the largest number possible then we'll start getting negative values
    " which is no good.
    let g:seed = fmod(localtime(), 44488) + 1
endfunction

" TODO: Try to configure the cursor so it is not displayed. For terminal vim I
" believe the terminal itself would have to be configured from within vim. Or
" perhaps we could create highlighting to just conceal the cursor altogether?
" Looking at sneak.vim it seems that he has to do something to prevent that
" from happening so logically I should be able to make it happen.
" TODO: Consider using randomness from the system to generate random numbers:
" http://stackoverflow.com/questions/20430493/how-to-generate-random-numbers-in-the-buffer
" http://stackoverflow.com/questions/3062746/special-simple-random-number-generator
function! GetRand()
    let a = 48271
    let c = 0
    let m = 2147483647
    let g:seed = fmod(a * g:seed + c, m)
    return g:seed
endfunction

function! IntegerModulo(dividend, divisor)
    return float2nr(fmod(a:dividend, a:divisor))
endfunction

function! GetNumActiveBits(num)
    let n = a:num
    let c = 0
    while n
        if IntegerModulo(n, 2)
            let c += 1
        endif
        let n = n / 2
    endwhile
    return c
endfunction

function! CalculateLookupTableEntry(n_state)
    let cell_state = IntegerModulo(a:n_state / 16, 2)
    let living_count = GetNumActiveBits(a:n_state)
    if living_count == 3
        return 1
    elseif living_count == 4
        return cell_state
    else
        return 0
    endif
endfunction

function! InitializeScreenSaver()
    " Open up a blank buffer
    -tabedit
    " Maximize screen space
    let g:save_laststatus = &laststatus
    let g:save_showtabline = &showtabline
    setlocal nonumber
    setlocal nocursorline
    setlocal nocursorcolumn
    set laststatus=0
    set showtabline=0
endfunction

function! InitializeGameOfLife()
    " Highlight the living cells
    highlight LivingCell term=reverse cterm=reverse gui=reverse
    syntax match LivingCell "\#"

    let g:update_speed = 100
    " Add 2 for the two rows of padding
    let g:width = &columns + 2
    " Subtract 1 for the command line window
    let g:height = &lines - 1 + 2
    let g:update_buffer = []
    let g:board = []
    let g:lookup_table = []

    " Create an empty board
    for y in range(0, g:height-1)
        call add(g:board, repeat([0], g:width))
    endfor

    call SeedRNG()
    " Be sure to only initialize the non-padding areas
    for y in range(1, g:height-2)
        for x in range(1, g:width-2)
            let g:board[y][x] = IntegerModulo(GetRand(), 2)
        endfor
    endfor
    for i in range(0, 511)
        call add(g:lookup_table, CalculateLookupTableEntry(i))
    endfor
endfunction

function! QuitScreenSaver()
    let &laststatus = g:save_laststatus
    let &showtabline = g:save_showtabline
    bdelete!
endfunction

function! DisplayBoard()
    " Be sure to only display the non-padded part of the data structure
    for y in range(1, g:height-2)
        let line = ''
        for x in range(1, g:width-2)
            let cell = ' '
            if g:board[y][x]
                let cell = '#'
            endif
            let line = line . cell
        endfor
        call setline(y, line)
    endfor
    redraw
endfunction

function! UpdateBoard()
    " TODO: See if doing a copy on each row would be more efficient or not
    let g:update_buffer = deepcopy(g:board)
    " Be sure to only display the non-padded part of the data structure
    for y in range(1, g:height-2)
        let n_state = 0
        if g:update_buffer[y-1][0] | let n_state += 32 | endif
        if g:update_buffer[y-1][1] | let n_state += 4  | endif
        if g:update_buffer[y  ][0] | let n_state += 16 | endif
        if g:update_buffer[y  ][1] | let n_state += 2  | endif
        if g:update_buffer[y+1][0] | let n_state += 8  | endif
        if g:update_buffer[y+1][1] | let n_state += 1  | endif
        for x in range(1, g:width-2)
            let n_state = IntegerModulo(n_state, 64) * 8
            if g:update_buffer[y-1][x+1] | let n_state += 4 | endif
            if g:update_buffer[y  ][x+1] | let n_state += 2 | endif
            if g:update_buffer[y+1][x+1] | let n_state += 1 | endif
            let g:board[y][x] = g:lookup_table[n_state]
        endfor
    endfor
endfunction

function! GameLoop()
    while 1
        " Quit if any character is pressed
        if getchar(0)
            break
        endif
        call DisplayBoard()
        call UpdateBoard()
    endwhile
endfunction

function! GameOfLife()
    call InitializeScreenSaver()
    call InitializeGameOfLife()
    call GameLoop()
    call QuitScreenSaver()
endfunction

command! ScreenSaver call GameOfLife()

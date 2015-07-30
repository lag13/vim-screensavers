" nnoremap Q :call QuitScreenSaver()<CR>
" augroup quit_screensaver
"     autocmd!
"     autocmd CursorMoved <buffer> call QuitScreenSaver | autocmd! quit_screensaver
" augroup END

function! SeedRNG()
    " I mod it by 44488 because 48271 * 44488 is the largest number that is
    " still less than 2147483647 (the largest number possible). If we go over
    " the largest number possible then we'll start getting negative values
    " which is no good.
    let g:seed = fmod(localtime(), 44488) + 1
endfunction

" TODO: Consider drawing the cells using highlighting rather than
" octothorpes.
" TODO: Consider using randomness from the system:
" http://stackoverflow.com/questions/20430493/how-to-generate-random-numbers-in-the-buffer
" http://stackoverflow.com/questions/3062746/special-simple-random-number-generator
function! GetRand()
    let a = 48271
    let c = 0
    let m = 2147483647
    let g:seed = fmod(a * g:seed + c, m)
    return g:seed
endfunction

" TODO: Reuse the last buffer I used if it exists.
function! InitializeScreenSaver()
    let g:seed = 0
    let g:update_speed = 100
    " Add 2 for the two rows of padding
    let g:width = &columns + 2
    " Subtract 1 for the command line window
    let g:height = &lines - 1 + 2
    let g:update_buffer = []
    let g:board = []
    let g:lookup_table = []
    let g:save_laststatus = &laststatus
    let g:save_showtabline = &showtabline

    -tabedit
    " Create an empty board
    for y in range(0, g:height-1)
        call add(g:board, [])
        for x in range(0, g:width-1)
            call add(g:board[y], 0)
        endfor
    endfor
    " Turn off options to maximize screen space
    setlocal nonumber
    set laststatus=0
    set showtabline=0
endfunction

function! QuitScreenSaver()
    let &laststatus = g:save_laststatus
    let &showtabline = g:save_showtabline
    tabclose
endfunction

function! GetNumActiveBits(num)
    let n = a:num
    let c = 0
    while n
        if float2nr(fmod(n, 2))
            let c += 1
        endif
        let n = n / 2
    endwhile
    return c
endfunction

function! CalculateLookupTableEntry(state)
    let cell_state = float2nr(fmod(a:state / 16, 2))
    let living_count = GetNumActiveBits(a:state)
    if living_count == 3
        return 1
    elseif living_count == 4
        return cell_state
    else
        return 0
    endif
endfunction

function! InitializeDataStructures()
    call SeedRNG()
    " Be sure to only initialize the non-padding areas
    for y in range(1, g:height-2)
        for x in range(1, g:width-2)
            let g:board[y][x] = float2nr(fmod(GetRand(), 2))
        endfor
    endfor
    for i in range(0, 511)
        call add(g:lookup_table, CalculateLookupTableEntry(i))
    endfor
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
    redraw!
endfunction

function! LivesOrDies(cellState, numLivingNeighbors)
    let numLiving = a:cellState + a:numLivingNeighbors
    if numLiving == 3
        return 1
    elseif numLiving == 4
        return a:cellState
    else
        return 0
    endif
endfunction

function! UpdateBoard()
    " TODO: See if doing a copy on each row would be more efficient or not
    let g:update_buffer = deepcopy(g:board)
    " Be sure to only display the non-padded part of the data structure
    let environment = 0
    for y in range(1, g:height-2)
        if g:update_buffer[y-1][0] | let environment += 32 | endif
        if g:update_buffer[y-1][1] | let environment += 4  | endif
        if g:update_buffer[y  ][0] | let environment += 16 | endif
        if g:update_buffer[y  ][1] | let environment += 2  | endif
        if g:update_buffer[y+1][0] | let environment += 8  | endif
        if g:update_buffer[y+1][1] | let environment += 1  | endif
        for x in range(1, g:width-2)
            let environment = float2nr(fmod(environment, 64)) * 8
            if g:update_buffer[y-1][x+1] | let environment += 4 | endif
            if g:update_buffer[y  ][x+1] | let environment += 2 | endif
            if g:update_buffer[y+1][x+1] | let environment += 1 | endif
            let g:board[y][x] = g:lookup_table[environment]
        endfor
    endfor
endfunction

function! GetCellStateToroidal(x, y)
    if a:y == -1
        let row = g:height - 1
    elseif a:y == g:height
        let row = 0
    endif
    if a:x == -1
        let col = g:width - 1
    elseif a:x == g:width
        let col = 0
    endif
    return g:board[row][col]
endfunction

function! GameLoop()
    while 1
        call DisplayBoard()
        call UpdateBoard()
        execute "sleep ".g:update_speed."m"
    endwhile
endfunction

function! GameOfLife()
    call InitializeScreenSaver()
    call InitializeDataStructures()
    call GameLoop()
endfunction

command! ScreenSaver call GameOfLife()

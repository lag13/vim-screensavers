function! BuildLookupTable(rule_number)
    let rule_num = a:rule_number
    let g:lookup_table = repeat([0], 8)
    for i in range(0, 7)
        let rem = rule_num % 2
        let rule_num = rule_num / 2
        let g:lookup_table[i] = rem
    endfor
endfunction

function! GetNextState(lc, mc, rc)
    let l = 4 * a:lc
    let c = 2 * a:mc
    let m =     a:rc
    return g:lookup_table[l + c + m]
endfunction

function! InitializeElementary(rule_num)
    " Add 2 for the two rows of padding
    let g:width = &columns + 2
    " Subtract 1 for the command line window
    let g:height = &lines - 1
    let g:update_buffer = []
    let g:board = []
    let g:draw_buffer = []
    let g:generation_num = 1
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

    call BuildLookupTable(a:rule_num)

    " Create an empty draw buffer
    for y in range(0, g:height-1)
        call add(g:draw_buffer, repeat(' ', g:width-2))
    endfor

    " Create an empty board
    let g:board = repeat([0], g:width)
    let g:update_buffer = repeat([0], g:width)
    " Initialize the board
    call SeedRNG(localtime())
    " Be sure to only initialize the non-padding areas
    " for x in range(1, g:width-2)
    "     let g:board[x] = GetRand() % 2
    " endfor
    let g:board[60] = 1
    call UpdateDrawBuffer(g:generation_num)
endfunction

function! UpdateDrawBuffer(generation_num)
    let line = ''
    for x in range(1, g:width-2)
        let char = ' '
        if g:board[x]
            let char = '#'
        endif
        let line = line . char
    endfor
    let g:draw_buffer[a:generation_num-1] = line
endfunction

function! DisplayBoard2()
    for y in range(0, g:height-1)
        call setline(y+1, g:draw_buffer[y])
    endfor
    redraw
endfunction

function! UpdateBoard2()
    " TODO: See if doing a copy on each row would be more efficient or not
    " Be sure to only display the non-padded part of the data structure
    for x in range(1, g:width-2)
        let g:update_buffer[x] = GetNextState(g:board[x-1], g:board[x], g:board[x+1])
    endfor
    let g:board = copy(g:update_buffer)

    " Update the draw buffer
    if g:generation_num == g:height
        for g in range(0, g:height-2)
            let g:draw_buffer[g] = g:draw_buffer[g+1]
        endfor
    else
        let g:generation_num += 1
    endif
    call UpdateDrawBuffer(g:generation_num)
endfunction

function! GameLoop2()
    while 1
        " Quit if any character is pressed
        if getchar(0)
            break
        endif
        call DisplayBoard2()
        call UpdateBoard2()
        sleep 100m
    endwhile
endfunction

function! Elementary(rule_num)
    call InitializeScreenSaver()
    call InitializeElementary(a:rule_num)
    call GameLoop2()
    call QuitScreenSaver()
endfunction

command! -nargs=1 ScreenSaver2 call Elementary(<f-args>)

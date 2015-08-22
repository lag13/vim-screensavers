" TODO: Maybe make the spiral destroy the code currently on the page. So copy
" the current page of code to the new buffer and then run the spiral on top of
" it.
function! InitializeUzumaki()
    for y in range(1, &lines-1)
        call setline(y, repeat(' ', &columns))
    endfor
endfunction

function! SpiralPos(t, columns, lines, dx, dy, start_col, start_line)
    return SpiralPosHelper(a:t, 0, a:columns, a:lines-1, a:dx, a:dy, a:start_col, a:start_line)
endfunction

" which_arm | meaning
" ----------+--------
"     0     | top arm
"     1     | right arm
"     2     | bottom arm
"     3     | left arm
function! SpiralPosHelper(t, which_arm, cur_arm_len, prev_arm_len, cur_delta, prev_delta, col, line)
    if a:t < a:cur_arm_len " t falls somewhere on the current arm
        return NextSpiralPos(a:which_arm, a:line, a:col, a:t, 0)
    elseif a:cur_arm_len < a:cur_delta " The spiral has gone as far as possible
        return [a:line, a:col]
    else
        let [new_line, new_col] = NextSpiralPos(a:which_arm, a:line, a:col, a:cur_arm_len-1, 1)
        let new_t = a:t - a:cur_arm_len
        let next_arm = (a:which_arm + 1) % 4
        let cur_arm_new_len = a:cur_arm_len - a:cur_delta
        return SpiralPosHelper(new_t, next_arm, a:prev_arm_len, cur_arm_new_len, a:prev_delta, a:cur_delta, new_col, new_line)
    endif
endfunction

function! NextSpiralPos(which_arm, line, col, change, nudge)
    if a:which_arm == 0
        return [a:line+a:nudge, a:col+a:change]
    elseif a:which_arm == 1
        return [a:line+a:change, a:col-a:nudge]
    elseif a:which_arm == 2
        return [a:line-a:nudge, a:col-a:change]
    else
        return [a:line-a:change, a:col+a:nudge]
    endif
endfunction

function! MaxTvalue(columns, lines, dx, dy)
    return MaxTvalueHelper(a:columns, a:lines-1, a:dx, a:dy, -1)
endfunction

function! MaxTvalueHelper(cur_arm_len, next_arm_len, cur_delta, prev_delta, max_t)
    if a:cur_arm_len < a:cur_delta
        return a:max_t + a:cur_arm_len
    else
        return MaxTvalueHelper(a:next_arm_len, a:cur_arm_len-a:cur_delta, a:prev_delta, a:cur_delta, a:max_t+a:cur_arm_len)
    endif
endfunction

function! DrawSpiral(spiral_path, char, ms)
    for pos in a:spiral_path
        if getchar(0)
            return 1
        endif
        call cursor(pos)
        execute "normal! r".a:char
        redraw
        if a:ms > 0
            execute "sleep ".a:ms."m"
        endif
    endfor
    return 0
endfunction

function! UzumakiLoop()
    let width = &columns
    let height = &lines - 1
    let start_col = 1
    let start_line = 1
    let dx = 3
    let dy = 2
    let sleep_len = 3
    let spiral_path = []
    " Build the spiral
    for t in range(0, MaxTvalue(width, height, dx, dy))
        let pos = SpiralPos(t, width, height, dx, dy, start_col, start_line)
        call add(spiral_path, pos)
    endfor
    let rev_sp = reverse(copy(spiral_path))
    while 1
        if DrawSpiral(spiral_path, '#', sleep_len)
            break
        endif
        if DrawSpiral(spiral_path, ' ', sleep_len)
            break
        endif
        if DrawSpiral(rev_sp, '#', sleep_len)
            break
        endif
        if DrawSpiral(rev_sp, ' ', sleep_len)
            break
        endif
    endwhile
endfunction

function! Uzumaki()
    call InitializeScreenSaver()
    call InitializeUzumaki()
    call UzumakiLoop()
    call QuitScreenSaver()
endfunction

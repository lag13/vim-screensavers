" TODO: Maybe make the spiral destroy the code currently on the page. So copy
" the current page of code to the new buffer and then run the spiral on top of
" it.
function! InitializeUzumaki()
    for y in range(1, &lines-1)
        call setline(y, repeat(' ', &columns))
    endfor
endfunction

function! SpiralPos(t, columns, lines, dx, dy, start_col, start_line)
    let top_arm_len = a:columns
    let right_arm_len = a:lines - 1
    let bottom_arm_len = top_arm_len - a:dx
    let left_arm_len = right_arm_len - a:dy
    let my_t = a:t

    if a:columns < 1 || a:lines < 1
        return [0, 0]
    endif

    if my_t < top_arm_len
        return [a:start_line, a:start_col + my_t]
    endif
    let my_t = my_t - top_arm_len

    if my_t < right_arm_len
        return [a:start_line + my_t + 1, a:start_col + a:columns - 1]
    endif
    let my_t = my_t - right_arm_len

    if my_t < bottom_arm_len
        return [a:lines + a:start_line - 1, a:start_col + a:columns - 2 - my_t]
    endif
    let my_t = my_t - bottom_arm_len

    if my_t < left_arm_len
        return [a:start_line + a:lines - 2 - my_t, a:start_col + a:dx - 1]
    endif
    let my_t = my_t - left_arm_len

    return SpiralPos(my_t, a:columns - 2*a:dx, a:lines - 2*a:dy, a:dx, a:dy, a:start_col+a:dx, a:start_line+a:dy)
endfunction

function! NewSpiralPos(t, columns, lines, dx, dy, start_col, start_line)
    return NewSpiralPosHelper(a:t, 0, a:columns, a:lines-1, a:dx, a:dy, a:start_col, a:start_line)
endfunction

function! NewSpiralPosHelper(t, which_arm, cur_arm_len, prev_arm_len, cur_delta, prev_delta, col, line)
    if a:cur_arm_len < 1
        return [a:line, a:col]
    elseif a:t < a:cur_arm_len
        return NextSpiralPos(a:which_arm, a:line, a:col, a:t, 0)
    else
        let [new_line, new_col] = NextSpiralPos(a:which_arm, a:line, a:col, a:cur_arm_len-1, 1)
        let new_t = a:t - a:cur_arm_len
        let next_arm = (a:which_arm + 1) % 4
        let cur_arm_new_len = a:cur_arm_len - a:cur_delta
        return NewSpiralPosHelper(new_t, next_arm, a:prev_arm_len, cur_arm_new_len, a:prev_delta, a:cur_delta, new_col, new_line)
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

function! MaxTvalueHelper(cur_arm_len, prev_arm_len, cur_delta, prev_delta, max_t)
    if a:cur_arm_len < 1
        return a:max_t
    else
        return MaxTvalueHelper(a:prev_arm_len, a:cur_arm_len-a:cur_delta, a:prev_delta, a:cur_delta, a:max_t+a:cur_arm_len)
    endif
endfunction

" TODO: Test this with some really weird inputs like 10 columns and 1 line.
" This currently seems to mess up the center of the spiral when: dx = 5, dy =
" 2, width = 66, height = 22. Look into it.
function! UzumakiLoop()
    let width = &columns
    let height = &lines - 1
    let start_col = 1
    let start_line = 1
    let dx = 5
    let dy = 2
    let g:spiral_path = []
    let g:spiral_len = MaxTvalue(width, height, dx, dy)
    " Build the spiral
    for t in range(0, g:spiral_len)
        let pos = SpiralPos(t, width, height, dx, dy, start_col, start_line)
        call add(g:spiral_path, pos)
    endfor
    " Draw the spiral for the first time
    for pos in g:spiral_path
        if getchar(0)
            return
        endif
        call cursor(pos)
        execute "normal! r#"
        redraw
        sleep 10m
    endfor
    for pos in g:spiral_path
        if getchar(0)
            return
        endif
        call cursor(pos)
        execute "normal! r "
        redraw
        sleep 10m
    endfor
    call reverse(g:spiral_path)
    for pos in g:spiral_path
        if getchar(0)
            return
        endif
        call cursor(pos)
        execute "normal! r#"
        redraw
        sleep 10m
    endfor
    for pos in g:spiral_path
        if getchar(0)
            return
        endif
        call cursor(pos)
        execute "normal! r "
        redraw
        sleep 10m
    endfor
endfunction

function! Uzumaki()
    call InitializeScreenSaver()
    call InitializeUzumaki()
    call UzumakiLoop()
    call QuitScreenSaver()
endfunction

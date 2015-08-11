function! InitializeUzumaki()
    let g:internal_data_structure = []
    let g:draw_buffer = []
    let g:spiral_tip_pos = [0, 0]
    let g:dy = 0
    let g:dx = 1
    let g:y_top_limit = 0
    let g:y_bottom_limit = &lines-1
    let g:x_left_limit = 0
    let g:x_right_limit = &columns-1

    for y in range(0, &lines-1)
        call add(g:internal_data_structure, repeat([0], &columns))
        call add(g:draw_buffer, repeat(' ', &columns))
    endfor
endfunction

function! DisplayUzumaki()
    for y in range(0, &lines-1)
        call setline(y+1, g:draw_buffer[y])
    endfor
    redraw
endfunction

function! DrawToBuffer()
    for y in range(0, &lines-1)
        let line = ''
        for x in range(0, &columns-1)
            let cell = ' '
            if g:internal_data_structure[y][x]
                let cell = '#'
            endif
            let line = line . cell
        endfor
        let g:draw_buffer[y] = line
    endfor
endfunction

function! UpdateSpiral()
    let g:internal_data_structure[g:spiral_tip_pos[0]][g:spiral_tip_pos[1]] = 1
    call FurtherSpiralTip()
endfunction

function! FurtherSpiralTip()
    let row = g:spiral_tip_pos[0]
    let col = g:spiral_tip_pos[1]
    if col == g:x_right_limit && row == g:y_top_limit
        let g:dy = 1
        let g:dx = 0
        let g:x_left_limit = g:x_left_limit + 2
    elseif col == g:x_right_limit && row == g:y_bottom_limit
        let g:dy = 0
        let g:dx = -1
        let g:y_top_limit = g:y_top_limit + 1
    elseif col == g:x_left_limit && row == g:y_bottom_limit
        let g:dy = -1
        let g:dx = 0
        let g:x_right_limit = g:x_right_limit - 2
    elseif col == g:x_left_limit && row == g:y_top_limit
        let g:dy = 0
        let g:dx = 1
        let g:y_bottom_limit = g:y_bottom_limit - 1
    endif
    let g:spiral_tip_pos[0] = g:spiral_tip_pos[0] + g:dy
    let g:spiral_tip_pos[1] = g:spiral_tip_pos[1] + g:dx
endfunction

function! UzumakiLoop()
    while 1
        " Quit if any character is pressed
        if getchar(0)
            break
        endif
        call DisplayUzumaki()
        call UpdateSpiral()
        call DrawToBuffer()
    endwhile
endfunction

function! Uzumaki()
    call InitializeScreenSaver()
    call InitializeUzumaki()
    call UzumakiLoop()
    call QuitScreenSaver()
endfunction

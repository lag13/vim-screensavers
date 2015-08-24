let g:alphabet = {}
let g:char_width = 11
let g:char_height = 11

function! InitializeAlphabet()
    let zero = []
    call add(zero, " 000000000 ")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, "0         0")
    call add(zero, " 000000000 ")

    let one = []
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")
    call add(one, "     1     ")

    let two = []
    call add(two, "2222222222 ")
    call add(two, "          2")
    call add(two, "          2")
    call add(two, "          2")
    call add(two, "          2")
    call add(two, " 222222222 ")
    call add(two, "2          ")
    call add(two, "2          ")
    call add(two, "2          ")
    call add(two, "2          ")
    call add(two, " 222222222 ")

    let three = []
    call add(three, "3333333333 ")
    call add(three, "          3")
    call add(three, "          3")
    call add(three, "          3")
    call add(three, "          3")
    call add(three, "3333333333 ")
    call add(three, "          3")
    call add(three, "          3")
    call add(three, "          3")
    call add(three, "          3")
    call add(three, "3333333333 ")

    let four = []
    call add(four, "4         4")
    call add(four, "4         4")
    call add(four, "4         4")
    call add(four, "4         4")
    call add(four, "4         4")
    call add(four, " 444444444 ")
    call add(four, "          4")
    call add(four, "          4")
    call add(four, "          4")
    call add(four, "          4")
    call add(four, "          4")

    let five = []
    call add(five, " 5555555555")
    call add(five, "5          ")
    call add(five, "5          ")
    call add(five, "5          ")
    call add(five, "5          ")
    call add(five, " 555555555 ")
    call add(five, "          5")
    call add(five, "          5")
    call add(five, "          5")
    call add(five, "          5")
    call add(five, "5555555555 ")

    let six = []
    call add(six, " 6666666666")
    call add(six, "6          ")
    call add(six, "6          ")
    call add(six, "6          ")
    call add(six, "6          ")
    call add(six, " 666666666 ")
    call add(six, "6         6")
    call add(six, "6         6")
    call add(six, "6         6")
    call add(six, "6         6")
    call add(six, " 666666666 ")

    let seven = []
    call add(seven, "7777777777 ")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")
    call add(seven, "          7")

    let eight = []
    call add(eight, " 888888888 ")
    call add(eight, "8         8")
    call add(eight, "8         8")
    call add(eight, "8         8")
    call add(eight, "8         8")
    call add(eight, " 888888888 ")
    call add(eight, "8         8")
    call add(eight, "8         8")
    call add(eight, "8         8")
    call add(eight, "8         8")
    call add(eight, " 888888888 ")

    let nine = []
    call add(nine, " 999999999 ")
    call add(nine, "9         9")
    call add(nine, "9         9")
    call add(nine, "9         9")
    call add(nine, "9         9")
    call add(nine, " 999999999 ")
    call add(nine, "          9")
    call add(nine, "          9")
    call add(nine, "          9")
    call add(nine, "          9")
    call add(nine, "9999999999 ")

    let colon = []
    call add(colon, "           ")
    call add(colon, "    :::    ")
    call add(colon, "    :::    ")
    call add(colon, "    :::    ")
    call add(colon, "           ")
    call add(colon, "           ")
    call add(colon, "           ")
    call add(colon, "    :::    ")
    call add(colon, "    :::    ")
    call add(colon, "    :::    ")
    call add(colon, "           ")

    let g:alphabet['0'] = zero
    let g:alphabet['1'] = one
    let g:alphabet['2'] = two
    let g:alphabet['3'] = three
    let g:alphabet['4'] = four
    let g:alphabet['5'] = five
    let g:alphabet['6'] = six
    let g:alphabet['7'] = seven
    let g:alphabet['8'] = eight
    let g:alphabet['9'] = nine
    let g:alphabet[':'] = colon
endfunction

function! ClockLoop()
    let dy = 1
    let dx = 1
    let line = 1
    let col = 1
    while 1
        if getchar(0)
            break
        endif
        let cur_time = GetCurTime()
        call DrawClock(GetClock(cur_time), [line, col])
        redraw
        sleep 100ms
        let [dy, dx] = ComputeDirection([line, col], g:char_height, GetStrLen(cur_time), dy, dx)
        let line = line + dy
        let col = col + dx
    endwhile
endfunction

function! GetStrLen(str)
    let separator_len = 3
    let str_len = strlen(a:str)
    return str_len*g:char_width+separator_len*str_len
endfunction

" Alters the direction of travel if we've hit an edge
function! ComputeDirection(upper_left_corner, height, width, dy, dx)
    let corner_line = a:upper_left_corner[0]
    let corner_col = a:upper_left_corner[1]
    let line_lower_limit = 1
    let line_upper_limit = &lines-1
    let col_lower_limit = 1
    let col_upper_limit = &columns
    let new_dy = a:dy
    let new_dx = a:dx

    if corner_line + a:dy < line_lower_limit
        let new_dy = -a:dy
    elseif corner_line + a:height + a:dy > line_upper_limit
        let new_dy = -a:dy
    endif
    if corner_col + a:dx < col_lower_limit
        let new_dx = -a:dx
    elseif corner_col + a:width + a:dx > col_upper_limit
        let new_dx = -a:dx
    endif

    return [new_dy, new_dx]
endfunction

function! DrawClock(clock, upper_left_corner)
    let corner_line = a:upper_left_corner[0]
    let corner_col = a:upper_left_corner[1]
    let empty_line = repeat(' ', &columns)
    for l in range(1, corner_line-1)
        call setline(l, empty_line)
    endfor
    for l in range(corner_line, corner_line + g:char_height - 1)
        let line = repeat(' ', corner_col-1) .  a:clock[l-corner_line]
        call setline(l, line)
    endfor
    for l in range(corner_line + g:char_height, &lines-1)
        call setline(l, empty_line)
    endfor
endfunction

function! GetClock(str)
    let spaces = "   "
    let result = []
    for i in range(0, g:char_height-1)
        let line = ""
        for j in range(0, strlen(a:str)-1)
            let line = line . get(g:alphabet, a:str[j])[i] . spaces
        endfor
        let line = strpart(line, 0, strlen(line) - strlen(spaces))
        call add(result, line)
    endfor
    return result
endfunction

function! GetCurTime()
    return strftime("%H:%M:%S")
endfunction

function! Clock()
    call InitializeScreenSaver()
    call InitializeAlphabet()
    call ClockLoop()
    call QuitScreenSaver()
endfunction


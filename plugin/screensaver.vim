function! SeedRNG(seed)
    let g:seed = a:seed % 509
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
    let a = 35
    let c = 1
    let m = 509
    let g:seed = (a * g:seed + c) % m
    return g:seed
endfunction

function! InitializeScreenSaver()
    " Open up a blank buffer
    -tabedit
    " Maximize screen space
    setlocal nonumber
    setlocal nocursorline
    setlocal nocursorcolumn
    let g:save_laststatus = &laststatus
    let g:save_showtabline = &showtabline
    set laststatus=0
    set showtabline=0
    " Generally, the screen will be filled with spaces as filler characters,
    " but we might want to draw a single colored square. Doing this lets us
    " draw that square using the tab character.
    setlocal noexpandtab
    setlocal tabstop=1
endfunction

function! QuitScreenSaver()
    let &laststatus = g:save_laststatus
    let &showtabline = g:save_showtabline
    bdelete!
endfunction

function! RunScreenSaver(ss_name, ...)
    let Ss_func = function(a:ss_name)
    if a:0
        call Ss_func(a:000)
    else
        call Ss_func()
    endif
endfunction

command! -nargs=* ScreenSaver call RunScreenSaver(<f-args>)
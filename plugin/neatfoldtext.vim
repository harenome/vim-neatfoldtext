" Forked from http://dhruvasagar.com/2013/03/28/vim-better-foldtext

if exists('g:loaded_NeatFoldText') || &cp
  finish
endif
let g:loaded_NeatFoldText = 1

let g:NeatFoldTextFancy = 1
if ! exists('g:NeatFoldTextFillChar')
    if exists('g:NeatFoldTextFancy') && g:NeatFoldTextFancy == 1
        let g:NeatFoldTextFillChar = '·'
    else
        let g:NeatFoldTextFillChar = matchstr(&fillchars, 'fold:\zs.')
    endif
elseif (strlen('g:NeatFoldTextFillChar') != 1)
    echohl WarningMsg
    echomsg "g:NeatFoldTextFillChar should be a single character."
    echohl NONE
    if exists('g:NeatFoldTextFancy') && g:NeatFoldTextFancy == 1
        let g:NeatFoldTextFillChar = '·'
    else
        let g:NeatFoldTextFillChar = matchstr(&fillchars, 'fold:\zs.')
    endif
endif

if ! exists('g:NeatFoldTextCountSurroundLeft')
    let g:NeatFoldTextCountSurroundLeft = '| '
endif

if ! exists('g:NeatFoldTextCountSurroundRight')
    let g:NeatFoldTextCountSurroundRight = ' |'
endif

if ! exists('g:NeatFoldTextSymbol')
    if exists('g:NeatFoldTextFancy') && g:NeatFoldTextFancy == 1
        let g:NeatFoldTextSymbol = '▶'
    else
        let g:NeatFoldTextSymbol = '+'
    endif
elseif (strlen('g:NeatFoldTextSymbol') != 1)
    echohl WarningMsg
    echomsg "g:NeatFoldTextSymbol should be a single character."
    echohl NONE
    let g:NeatFoldTextFillChar = matchstr(&fillchars, 'fold:\zs.')
endif

if ! exists('g:NeatFoldTextFoldLevel')
    let g:NeatFoldTextFoldLevel = '-'
elseif (strlen('g:NeatFoldTextFoldLevel') != 1)
    echohl WarningMsg
    echomsg "g:NeatFoldTextFoldLevel should be a single character."
    echohl NONE
    let g:NeatFoldTextFoldLevel = '-'
endif

let g:NeatFoldTextLineCount = 1

function! NeatFoldText()
    let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '

    if exists('g:NeatFoldTextLineCount') && g:NeatFoldTextLineCount == 0
        let lines_count_text = ''
    else
        let lines_count = v:foldend - v:foldstart + 1
        let lines_count_text = g:NeatFoldTextCountSurroundLeft . printf("%10s", lines_count . ' lines') . g:NeatFoldTextCountSurroundRight
    endif

    let foldtextstart = strpart(g:NeatFoldTextSymbol . repeat(g:NeatFoldTextFoldLevel, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(g:NeatFoldTextFillChar, 8)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
    return foldtextstart . repeat(g:NeatFoldTextFillChar, winwidth(0)-foldtextlength) . foldtextend
endfunction

set foldtext=NeatFoldText()

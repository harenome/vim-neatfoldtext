" Forked from http://dhruvasagar.com/2013/03/28/vim-better-foldtext
if exists('g:loaded_NeatFoldText') || &cp
  finish
endif
let g:loaded_NeatFoldText = 1

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

if ! exists('g:NeatFoldTextFoldLevelScale')
    let g:NeatFoldTextFoldLevelScale = 1
endif

" if ! &expandtab
"     let g:NeatFoldTextIndentSize = &tabstop
" else
"     let g:NeatFoldTextIndentSize = 1
" endif

function! NeatFoldText()
    " If multiline comments start with a '/*' or '/**' on a separate line.
    if match(getline(v:foldstart), '^\s*/\*\+\s*$') == -1
        let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    else
        let line = ' ' . substitute(getline(v:foldstart + 1), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    endif

    " Number of lines
    if exists('g:NeatFoldTextLineCount') && g:NeatFoldTextLineCount == 0
        let lines_count_text = ''
    else
        " let lines_count = v:foldend - v:foldstart + 1
        let lines_count_text = g:NeatFoldTextCountSurroundLeft
        let lines_count_text = lines_count_text . printf("%10s", v:foldend - v:foldstart + 1 . ' lines')
        let lines_count_text = lines_count_text . g:NeatFoldTextCountSurroundRight
    endif

    if exists('g:NeatFoldTextIndent') && g:NeatFoldTextIndent == 1 && match(getline(v:foldstart), '^\s\+') != -1
        " let foldindent = repeat(' ', match(getline(v:foldstart), '\S') * g:NeatFoldTextIndentSize)
        let foldindent = repeat(' ', match(getline(v:foldstart), '\S'))
    else
        let foldindent = ''
    endif

    let foldlevel = repeat(g:NeatFoldTextFoldLevel, v:foldlevel * g:NeatFoldTextFoldLevelScale)

    let foldtextstart = strpart(foldindent . g:NeatFoldTextSymbol . foldlevel  . line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(g:NeatFoldTextFillChar, 8)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
    return foldtextstart . repeat(g:NeatFoldTextFillChar, winwidth(0)-foldtextlength) . foldtextend
endfunction

set foldtext=NeatFoldText()

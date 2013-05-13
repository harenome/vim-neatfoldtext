" Forked from http://dhruvasagar.com/2013/03/28/vim-better-foldtext
if exists('g:loaded_NeatFoldText') || &cp
  finish
endif
let g:loaded_NeatFoldText = 1

if exists('g:NeatFoldTextFancy') && g:NeatFoldTextFancy == 1
    if ! exists('g:NeatFoldTextFillChar') || strlen('g:NeatFoldTextFillChar') != 1
        let g:NeatFoldTextFillChar = '·'
    endif
    if ! exists('g:NeatFoldTextSymbol') || strlen('g:NeatFoldTextSymbol') != 1
        let g:NeatFoldTextSymbol = '▶'
    endif
    if ! exists('g:NeatFoldTextCountSurroundLeft')
        let g:NeatFoldTextCountSurroundLeft = '| '
    endif
    if ! exists('g:NeatFoldTextCountSurroundRight')
        let g:NeatFoldTextCountSurroundRight = ' |'
    endif
    if ! exists('g:NeatFoldTextFoldLevelSymbol') || strlen('g:NeatFoldTextFoldLevelSymbol') != 1
        let g:NeatFoldTextFoldLevelSymbol = '-'
    endif
    if ! exists('g:NeatFoldTextFoldLevelScale')
        let g:NeatFoldTextFoldLevelScale = 0
    endif
    if ! exists('g:NeatFoldTextIndent')
        let g:NeatFoldTextIndent = 1
    endif

    if ! exists('g:NeatFoldTextShowLineCount')
        let g:NeatFoldTextShowLineCount = 1
    endif
else
    if ! exists('g:NeatFoldTextFillChar') || strlen('g:NeatFoldTextFillChar') != 1
        let g:NeatFoldTextFillChar = matchstr(&fillchars, 'fold:\zs.')
    endif

    if ! exists('g:NeatFoldTextSymbol') || strlen('g:NeatFoldTextSymbol') != 1
        let g:NeatFoldTextSymbol = '+'
    endif

    if ! exists('g:NeatFoldTextCountSurroundLeft')
        let g:NeatFoldTextCountSurroundLeft = '| '
    endif

    if ! exists('g:NeatFoldTextCountSurroundRight')
        let g:NeatFoldTextCountSurroundRight = ' |'
    endif

    if ! exists('g:NeatFoldTextFoldLevelSymbol') || strlen('g:NeatFoldTextFoldLevelSymbol') != 1
        let g:NeatFoldTextFoldLevelSymbol = '-'
    endif

    if ! exists('g:NeatFoldTextFoldLevelScale')
        let g:NeatFoldTextFoldLevelScale = 1
    endif

    if ! exists('g:NeatFoldTextIndent')
        let g:NeatFoldTextIndent = 0
    endif

    if ! exists('g:NeatFoldTextShowLineCount')
        let g:NeatFoldTextShowLineCount = 1
    endif
endif

function! NeatFoldText()
    " If multiline comments start with a '/*' or '/**' on a separate line.
    if match(getline(v:foldstart), '^\s*/\*\+\s*$') == -1
        let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    else
        let line = ' ' . substitute(getline(v:foldstart + 1), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    endif

    " Number of lines
    if g:NeatFoldTextShowLineCount == 0
        let lines_count_text = ''
    else
        " let lines_count = v:foldend - v:foldstart + 1
        let lines_count_text = g:NeatFoldTextCountSurroundLeft
        let lines_count_text = lines_count_text . printf("%10s", v:foldend - v:foldstart + 1 . ' lines')
        let lines_count_text = lines_count_text . g:NeatFoldTextCountSurroundRight
    endif

    let foldindent = ''
    if g:NeatFoldTextIndent == 1
        if match(getline(v:foldstart), '^ \+\S') != -1
            let foldindent = repeat(' ', match(getline(v:foldstart), '\S'))
        elseif match(getline(v:foldstart), '^\t\+\S') != -1
            let foldindent = repeat(' ', match(getline(v:foldstart), '\S') * &tabstop)
        " If the indentation of the current line is a mix of spaces and tabs...
        " shall we bother?
        endif
    endif

    let foldlevel = repeat(g:NeatFoldTextFoldLevelSymbol, v:foldlevel * g:NeatFoldTextFoldLevelScale)

    let foldtextstart = strpart(foldindent . g:NeatFoldTextSymbol . foldlevel . line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(g:NeatFoldTextFillChar, 8)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
    return foldtextstart . repeat(g:NeatFoldTextFillChar, winwidth(0)-foldtextlength) . foldtextend
endfunction

set foldtext=NeatFoldText()

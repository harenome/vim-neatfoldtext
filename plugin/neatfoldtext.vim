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
        " TODO: Test utf8, etc.
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

    if ! exists('g:NeatFoldTextCountCommentsLines')
        let g:NeatFoldTextCountCommentsLines = 1
    endif

    if ! exists('g:NeatFoldTextZenComments')
        let g:NeatFoldTextZenComments = 1
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

    if ! exists('g:NeatFoldTextCountCommentsLines')
        let g:NeatFoldTextCountCommentsLines = 0
    endif

    if ! exists('g:NeatFoldTextZenComments')
        let g:NeatFoldTextZenComments = 0
    endif
endif

function! NeatFoldText()
    " Check if multiline comments start with a '/\*\+' on a separate line.
    if match(getline(v:foldstart), '^\s*/\*\+\s*$') == -1
        " Dirty workaround for marker folding with common single line
        " comment symbols ('"', '//', '#'...)
        let line = getline(v:foldstart)
        let line = substitute(line, '^\s*"*\s*\|\s*"*\s*{{' . '{\d*\s*', '', 'g')
        let line = substitute(line, '^\s*#*\s*\|\s*#*\s*{{' . '{\d*\s*', '', 'g')
        let line = substitute(line, '^\s*/\{2,}\s*\|\s*/\{2,}\s*{{' . '{\d*\s*', '', 'g')
        let line = ' ' . line . ' '
    else
        " Use the next line in the comment block, and add the '/*' or '/**'
        " so that we know it's a block of comments or doc.
        let line = ' ' . substitute(getline(v:foldstart), '\s*', '', 'g') . ' '
        let line = line . substitute(getline(v:foldstart + 1), '^\s*\*\+\s*', '', 'g') . ' '
    endif

    " Number of lines
    let lines_count_text = ''
    if g:NeatFoldTextShowLineCount == 1
        \ && (g:NeatFoldTextCountCommentsLines == 1 || match(getline(v:foldstart), '^\s*/\*\+') == -1)
        let lines_count_text = g:NeatFoldTextCountSurroundLeft
        let lines_count_text = lines_count_text . printf("%10s", v:foldend - v:foldstart + 1 . ' lines')
        let lines_count_text = lines_count_text . g:NeatFoldTextCountSurroundRight
    endif

    let foldindent = ''
    if g:NeatFoldTextIndent == 1
        " Indent the foldtext according to the current line
        if match(getline(v:foldstart), '^ \+\S') != -1
            let foldindent = repeat(' ', match(getline(v:foldstart), '\S'))
        elseif match(getline(v:foldstart), '^\t\+\S') != -1
            let foldindent = repeat(' ', match(getline(v:foldstart), '\S') * &tabstop)
        " If the indentation of the current line is a mix of spaces and tabs...
        " shall we bother?
        endif
    endif

    let foldlevel = repeat(g:NeatFoldTextFoldLevelSymbol, v:foldlevel * g:NeatFoldTextFoldLevelScale)

    " TODO:
    " - Show that the text is being cut, when it is being cut.
    " - Cut at 80 chars? (Well...a bit less than 80, if we want to show it's
    "   being cut...)
    " - Put line count back to left?
    let foldtextstart = strpart(foldindent . g:NeatFoldTextSymbol . foldlevel . line, 0, (winwidth(0)*2)/3)
    if match(getline(v:foldstart), '^\s*/\*\+') != -1 && g:NeatFoldTextZenComments == 1
        return foldtextstart . repeat(' ', winwidth(0) - strlen(foldtextstart) - &foldcolumn)
    else
        let foldtextend = lines_count_text . repeat(g:NeatFoldTextFillChar, 8)
        let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
        return foldtextstart . repeat(g:NeatFoldTextFillChar, winwidth(0)-foldtextlength) . foldtextend
    endif
endfunction

set foldtext=NeatFoldText()

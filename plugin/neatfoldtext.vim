"==============================================================================
" Plugin: NeatFoldText
" Maintainer: Harenome Ranaivoarivony Razanajato <harno.ranaivo@gmail.com>
" URL: https://github.com/HarnoRanaivo/vim-neatfoldtext
" Version: 0.1
"
" It started from http://dhruvasagar.com/2013/03/28/vim-better-foldtext
"==============================================================================

if exists('g:loaded_NeatFoldText') || &cp
  finish
endif
let g:loaded_NeatFoldText = 1

" Functions {{{

function s:SetFancyFoldText() "{{{
    if ! exists('g:NeatFoldTextFillChar') || strlen('g:NeatFoldTextFillChar') != 1
        let g:NeatFoldTextFillChar = '·'
    endif
    if ! exists('g:NeatFoldTextSymbol') || strlen('g:NeatFoldTextSymbol') != 1
        " TODO: Test utf8, etc.
        let g:NeatFoldTextSymbol = '▸'
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
        let g:NeatFoldTextZenComments = 0
    endif
endfunction
"}}}

function s:SetClassicFoldText() "{{{
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
endfunction
"}}}

function s:IsCommentBlock() "{{{
    return match(getline(v:foldstart), '^\s*/\*\+') != -1
endfunction
"}}}

function s:FoldMarkerIsOnSeparateLine() "{{{
    return match(getline(v:foldstart), '^\s*["#/\*]*\s*{\{3}\d*\s*["#/\*]*$', 'g') != -1
endfunction
"}}}

function s:RemoveCommentSymbols(text) "{{{
    return substitute(a:text, '^\s*["#/\*]*\s*\|\s*["#/\*]*\s*{\{3}\d*\s*', '', 'g')
endfunction
"}}}

function s:GetFoldInfo() "{{{
    let info = ''
    " Check if multiline comments start with '/*' or '/**' on a separate line.
    if match(getline(v:foldstart), '^\s*/\*\+\s*$') != -1
        " Use the next line in the comment block, and add the '/*' or '/**'
        " so that we know it's a block of comments or doc.
        let info = substitute(getline(v:foldstart), '\s*', '', 'g') . ' '
        let info = info . substitute(getline(v:foldstart + 1), '^\s*\*\+\s*', '', 'g')
    elseif s:FoldMarkerIsOnSeparateLine()
        let info = getline(v:foldstart + 1)
        let info = s:RemoveCommentSymbols(info)
    elseif s:IsCommentBlock()
        let info = getline(v:foldstart)
    else
        let info = getline(v:foldstart)
        let info = s:RemoveCommentSymbols(info)
    endif
    let info = ' ' . info . ' '

    return info
endfunction
"}}}

function s:FormatLinesCount() "{{{
    let countText = ''
    if g:NeatFoldTextShowLineCount == 1
        \ && (g:NeatFoldTextCountCommentsLines == 1 || ! s:IsCommentBlock())
        if winwidth(0) < 60
            let countText = printf("%4s", v:foldend - v:foldstart + 1)
        else
            let countText = printf("%10s", v:foldend - v:foldstart + 1 . ' lines')
        endif

        let countText = g:NeatFoldTextCountSurroundLeft . countText . g:NeatFoldTextCountSurroundRight
    endif

    return countText
endfunction
"}}}

function s:IndentFold() "{{{
    let indent = ''
    if g:NeatFoldTextIndent == 1
        if match(getline(v:foldstart), '^ \+\S') != -1
            let indent = repeat(' ', match(getline(v:foldstart), '\S'))
        elseif match(getline(v:foldstart), '^\t\+\S') != -1
            let indent = repeat(' ', match(getline(v:foldstart), '\S') * &tabstop)
        " If the indentation of the current line is a mix of spaces and tabs...
        " shall we bother?
        endif
    endif

    return indent
endfunction
"}}}

function s:FormatFoldLevel() "{{{
    return repeat(g:NeatFoldTextFoldLevelSymbol, v:foldlevel * g:NeatFoldTextFoldLevelScale)
endfunction
"}}}

function s:CutText(text) "{{{
    let maxwidth = winwidth(0) * 2 / 3

    if strlen(a:text) > maxwidth
        return strpart(a:text, 0, maxwidth - 2) . '… '
    else
        return strpart(a:text, 0, maxwidth)
    endif
endfunction
"}}}

function s:PrintStart() "{{{
    let startText = s:IndentFold() . g:NeatFoldTextSymbol . s:FormatFoldLevel() . s:GetFoldInfo()
    let startText = s:CutText(startText)

    return startText
endfunction
"}}}

function! NeatFoldText() "{{{
    let startText = s:PrintStart()
    let linesCountText = s:FormatLinesCount()

    if s:IsCommentBlock() && g:NeatFoldTextZenComments == 1
        let fillLength = winwidth(0) - strlen(startText) - &foldcolumn
        return startText . repeat(' ', fillLength)
    else
        let endText = linesCountText . repeat(g:NeatFoldTextFillChar, 8)
        let fillLength = winwidth(0) - strlen(substitute(startText . endText, '.', 'x', 'g')) + &foldcolumn
        return startText . repeat(g:NeatFoldTextFillChar, fillLength) . endText
    endif
endfunction
"}}}

"}}}

" Init {{{
if exists('g:NeatFoldTextFancy') && g:NeatFoldTextFancy == 1
    call s:SetFancyFoldText()
else
    call s:SetClassicFoldText()
endif

set foldtext=NeatFoldText()
"}}}

"" Special settings for this file.
" vim:ft=vim:fdm=marker:ff=unix:foldopen=all:foldclose=all

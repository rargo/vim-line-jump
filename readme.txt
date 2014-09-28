When in Tagbar and NERDTree, It's not convenient jump lines using 'j','k'.
LineJump is written to make it easier

First, add to following default map to your .vimrc
    "LineJump NERDTree key map
    augroup LineJumpNerdTree
        "I find nerdtree's f map to something not that useful!
        autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> f <ESC>:silent! call LineJumpSelectForward()<cr>
        autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> ; <ESC>:silent! call LineJumpMoveForward()<cr>
        autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> b <ESC>:silent! call LineJumpSelectBackward()<cr>
        autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> , <ESC>:silent! call LineJumpMoveBackward()<cr>

        autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> gh <ESC>:silent! call LineJumpMoveTop()<cr>
        autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> gm <ESC>:silent! call LineJumpMoveMiddle()<cr>
        autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> gl <ESC>:silent! call LineJumpMoveBottom()<cr>
    augroup END

    "LineJump TagBar key map
    augroup LineJumpTagbar
        autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> f <ESC>:silent! call LineJumpSelectForward()<cr>
        autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> ; <ESC>:silent! call LineJumpMoveForward()<cr>
        autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> b <ESC>:silent! call LineJumpSelectBackward()<cr>
        autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> , <ESC>:silent! call LineJumpMoveBackward()<cr>

        autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> gh <ESC>:silent! call LineJumpMoveTop()<cr>
        autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> gm <ESC>:silent! call LineJumpMoveMiddle()<cr>
        autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> gl <ESC>:silent! call LineJumpMoveBottom()<cr>
    augroup END

It has two map key 'f', 'b' and a group of function to jump quickly in NERDTree and Tagbar(if you like, also can be enable in other buffer)

Here is how it works:
    in NERDTree or Tagbar, press 'f'(forward jump) or 'b'(backward jump), the first alpha will be highlight,
    previous selection often will have more than one match,  than:
        When g:LineJumpSelectMethod is 0:
            1. use ';' to move to next match
            2. use ',' to move to previous match
            3. use 'gh' to move to the first match
            4. use 'gm' to move to the middle match 
            5. use 'gl' to move to the last match
        When g:LineJumpSelectMethod is 1:
            highlight characters will be shown, press the conreponding
            key to jump to the line

Global option:
    g:LineJumpSelectMethod
        define sub select way, default is 0
        0: sub select by LineJumpSubForward(), LineJumpSubBackward()
            need to map these two functions to some key
        1: sub select by press number and alpha

    g:LineJumpSelectInVisable = 0
        only valid when g:LineJumpSelectMethod == 0, 
        if it is not 0, select will extend to the whole buffer,
        not just lines visabled in the window

    g:LineJumpMoveHighlight = 0
        only valid when g:LineJumpSelectMethod == 0, 
        if it is not 0, when move using ';',',', the candidate lines will highlight

rargo.m@gmail.com 2014.09.28
Distributed under the same terms as Vim itself.

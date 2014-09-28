LineJump is for people who is coming to mouse for help in vim

it has two map key 'f', 'b' and a group of function to jump quickly in NERDTree and Tagbar(if you like, can be enable in other buffer)

here is how it works:
    in NERDTree or Tagbar, press 'f'(forward jump) or 'b'(backward jump), the first alpha will be highlight,
	previous selection often will have more than one match,  than:
    1. use ';' to move to next match
    2. use ',' to move to previous match
    3. use 'gh' to move to the first match
    4. use 'gm' to move to the middle match 
    5. use 'gl' to move to the last match

global option:
g:LineJumpSelectMethod, define sub select way
    0: sub select by LineJumpSubForward(), LineJumpSubBackward()
        need to map these two functions to some key
    1: sub select by press number and alpha


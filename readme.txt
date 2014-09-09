I hate using 'j','k' to move between lines in NERDTree and Tagbar
I think some people will feel the same with me. 
Inspire by EasyMotion, I wrote this plugin vim-line-jump, try to make it better

it has two map key 'f', 'b' and a group of function to jump quickly in NERDTree and Tagbar(more than these)

here is how it works:
	in NERDTree or Tagbar, press 'f'(forward jump) or 'b'(backward jump), the first alpha will be highlight,
then press corresponding charater to jump to the line, if more than one line match, then there is sub selection, see below options

global option:
g:LineJumpSelectMethod, define sub select way
	0: sub select by press number and alpha
	1: sub select by "j,k,h,l,m", selection by key will be timeout
		after g:LineJumpPeepKeyTimeout milliseconds
	2: sub select by LineJumpSubForward(), LineJumpSubBackward()
		need to map these two functions to some key
	3: smart select, sub select by g:LineJumpSmartSelectMethod

g:LineJumpPeepKeyTimeout = 700
	peep key timeout milliseconds when use "j,k,h,l,m" to sub select line
	(Only effective when g:LineJumpSelectMethod == 1)

g:LineJumpSmartSelectNumber = 5
	if the first selection more than g:LineJumpSmartSelectNumber matchs, sub selection will use alpha, else will use method determined by g:LineJumpSmartSelectMethod
	(Only effective when g:LineJumpSelectMethod == 3 && g:LineJumpSmartSelectMethod == 0)
	0:  if match line less than g:LineJumpSmartSelectNumber
			sub select by "j,k,h,l,m",
		else sub select by alpha
	1:  if match line less than g:LineJumpSmartSelectNumber
			sub select by LineJumpSubForward(), LineJumpSubBackward(),
		else sub select by alpha

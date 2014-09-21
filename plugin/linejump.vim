"linejump, jump quickly by select line's first alpha
"rargo.m@gmail.com

"g:LineJumpSelectMethod, define sub select way
"	0: sub select by press number and alpha
"	2: sub select by LineJumpForwardMove(), LineJumpBackwardMove()
"		need to map these two functions to some key
"	3: smart select, sub select by g:LineJumpSmartSelectMethod
if !exists("g:LineJumpSelectMethod")
	let g:LineJumpSelectMethod = 2
endif
"Only effective when g:LineJumpSelectMethod == 1
if !exists("g:LineJumpPeepKeyTimeout")
	let g:LineJumpPeepKeyTimeout = 700
endif
"Only effective when g:LineJumpSelectMethod == 3 && g:LineJumpSmartSelectMethod == 0
if !exists("g:LineJumpSmartSelectNumber")
	let g:LineJumpSmartSelectNumber = 5
endif
"g:LineJumpSmartSelectMethod == 1:
"	if match line less than g:LineJumpSmartSelectNumber
"		sub select by LineJumpForwardMove(), LineJumpBackwardMove(),
"	else sub select by alpha
if !exists("g:LineJumpSmartSelectMethod")
	let g:LineJumpSmartSelectMethod = 1
endif

augroup LineJumpNerdTree
	"I find nerdtree's f map to something not that useful!
	autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> f <ESC>:call LineJumpForwardSelect()<cr>

	autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> ; <ESC>:call LineJumpForwardMove()<cr>

	autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> b <ESC>:call LineJumpBackwardSelect()<cr>

	autocmd BufEnter NERD_tree_\d\+ nnoremap <buffer> <nowait> <silent> , <ESC>:call LineJumpBackwardMove()<cr>
augroup END

augroup LineJumpTagbar
	autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> f <ESC>:call LineJumpForwardSelect()<cr>

	autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> ; <ESC>:call LineJumpForwardMove()<cr>

	autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> b <ESC>:call LineJumpBackwardSelect()<cr>

	autocmd BufEnter __Tagbar__ nnoremap <buffer> <nowait> <silent> , <ESC>:call LineJumpBackwardMove()<cr>
augroup END


let s:LineJumpCharacterDict = {}

let s:alpha_forward_list = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']

let s:alpha_line_map = {'a':0,'b':1,'c':2,'d':3,'e':4,'f':5,'g':6,'h':7,'i':8,'j':9,'k':10,'l':11,'m':12,'n':13,'o':14,'p':15,'q':16,'r':17,'s':18,'t':19,'u':20,'v':21,'w':22,'x':23,'y':24,'z':25,'A':26,'B':27,'C':28,'D':29,'E':30,'F':31,'G':32,'H':33,'I':34,'J':35,'K':36,'L':37,'M':38,'N':39,'O':40,'P':41,'Q':42,'R':43,'S':44,'T':45,'U':46,'V':47,'W':48,'X':49,'Y':50,'Z':51}
"let g:linelist = []

"borrow from easymotion
let s:target_hl_defaults = {
\   'gui'     : ['NONE', '#ff0000' , 'bold']
\ , 'cterm256': ['NONE', '196'     , 'bold']
\ , 'cterm'   : ['NONE', 'red'     , 'bold']
\ }

let s:target_select_defaults = {
\   'gui'     : ['NONE', '#0000ff' , 'bold']
\ , 'cterm256': ['NONE', '35'     , 'bold']
\ , 'cterm'   : ['NONE', 'green'     , 'bold']
\ }

" Reset highlighting after loading a new color scheme {{{
autocmd ColorScheme * call LineJumpLoadColor(s:target_hl_defaults,s:LineJumpHiGroup)
autocmd ColorScheme * call LineJumpLoadColor(s:target_select_defaults,s:LineJumpSelectGroup)

let s:LineJumpHiGroup = "LineJumpHiGroup"
let s:LineJumpSelectGroup = "LineJumpSelectGroup"

"load color for linejump
function! LineJumpLoadColor(colors,group)
		let groupdefault = a:group . 'Default'
		" Prepare highlighting variables
		let guihl = printf('guibg=%s guifg=%s gui=%s', a:colors.gui[0], a:colors.gui[1], a:colors.gui[2])
		if !exists('g:CSApprox_loaded')
			let ctermhl = &t_Co == 256
				\ ? printf('ctermbg=%s ctermfg=%s cterm=%s', a:colors.cterm256[0], a:colors.cterm256[1], a:colors.cterm256[2])
				\ : printf('ctermbg=%s ctermfg=%s cterm=%s', a:colors.cterm[0], a:colors.cterm[1], a:colors.cterm[2])
		else
			let ctermhl = ''
		endif

		" Create default highlighting group
		execute printf('hi default %s %s %s', groupdefault, guihl, ctermhl)
		" No colors are defined for this group, link to defaults
		execute printf('hi default link %s %s', a:group, groupdefault)
endfunction

"
let g:line_jump_post_action = {'__Tagbar__': "normal w",'NERD_tree_\d\+':"call Linejumpfirstword()", '.*':"normal zz"}
let g:line_jump_post_action_priority = ['__Tagbar__', 'NERD_tree_\d\+', '*']

function! Linejumpfirstword()
	let pos = getpos('.')
	let first_word_pos = match(getline('.'), '\w\+')
	if first_word_pos != -1
		let pos[2] = first_word_pos + 1
		call setpos('.',pos)
	endif
endfunction


"function! LineJumpSelectMethodByMotion(matchlinelist)
"		let hl_coords = []
"		for mline in a:matchlinelist
"			call add(hl_coords, '\%' . mline[0] . 'l\%' . (mline[1]+1) . 'c')
"		endfor
"
"		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
"		redraw
"
"		let charget = '#'
"		let current_index = 0
"		let max_index = len(a:matchlinelist) - 1
"		let newpos = getpos('.')
"		let newpos[1] = a:matchlinelist[current_index][0] "line number
"		let newpos[2] = a:matchlinelist[current_index][1] + 1 "column number
"		call setpos('.', newpos)
"		let select_coord = []
"		call add(select_coord, '\%' . newpos[1] . 'l\%' . newpos[2] . 'c')
"		let target_select_id = matchadd(s:LineJumpSelectGroup, join(select_coord, '\|'), 200)
"		redraw
"		while 9
"			"let key = getchar()
"			let key = PeekCharTimeout(g:LineJumpPeepKeyTimeout)
"			if key == 0
"				"let charget = ''
"				"echo "peek timeout"
"				break
"			endif
"			let key = getchar()
"			let char = nr2char(key)
"			if char == 'j'
"				let  current_index += 1
"				if current_index > max_index
"					let current_index = 0
"				endif
"			elseif char == 'k'
"				let  current_index -= 1
"				if current_index < 0
"					let current_index = max_index
"				endif
"			elseif char == 'm'
"				let  current_index = max_index/2
"			elseif char == 'l'
"				let  current_index = max_index
"			elseif char == 'h'
"				let  current_index = 0
"			else
"				let charget = char
"				break
"			endif
"			let newpos = getpos('.')
"			let newpos[1] = a:matchlinelist[current_index][0] "line number
"			let newpos[2] = a:matchlinelist[current_index][1] + 1 "column number
"			call setpos('.', newpos)
"			if exists('target_select_id')
"				call matchdelete(target_select_id)
"			endif
"			let select_coord = []
"			call add(select_coord, '\%' . newpos[1] . 'l\%' . newpos[2] . 'c')
"			let target_select_id = matchadd(s:LineJumpSelectGroup, join(select_coord, '\|'), 200)
"			redraw
"			"echo "char " . char
"		endwhile
"
"		if exists('target_select_id')
"			call matchdelete(target_select_id)
"		endif
"
"		if exists('target_hl_id')
"			call matchdelete(target_hl_id)
"		endif
"
"		"if charget != ' ' && charget != ''
"			"echo 'charget ' . charget
"			"execute "normal " . charget
"		"endif
"		"return charget
"endfunction

function! PeekCharTimeout(milli) 
    " non-consuming key-wait with timeout 
    let k=a:milli 
    while k > 0 && getchar(1) == 0 
        sleep 50m 
        let k = k - 50
    endwh 
    return getchar(1) 
endfun 

function! LineJumpSelectMethodByNumberAlpha(matchlinelist, startline, charget)
	"try
		let ki = 0
		let alpha_use_dict = {}
		let hl_coords = []
		for mline in a:matchlinelist
			let line = g:linelist[mline[0]-a:startline]
			let linereplace = substitute(line,a:charget,s:alpha_forward_list[ki],"") 
			call setline(mline[0],linereplace)
			call add(hl_coords, '\%' . mline[0] . 'l\%' . (mline[1]+1) . 'c')
			let alpha_use_dict[s:alpha_forward_list[ki]] = mline
			let ki += 1
		endfor

		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
		redraw

		"TODO handle error key 
		let charget = '#'
		while 9
			let key = getchar()
			let char = nr2char(key)
			"echo "char " . char
			if has_key(alpha_use_dict,char)
				let charget = char
				break
			endif
			"echo "linejump " . linejump
		endwhile

		let linefound = alpha_use_dict[charget]
		let newpos = getpos('.')
		let newpos[1] = linefound[0]
		let newpos[2] = linefound[1] + 1
		call setpos('.', newpos)
	"catch
	"finally
		if exists('target_hl_id')
			call matchdelete(target_hl_id)
		endif

		"restore line
		for mline in a:matchlinelist
			"echo "match pattern:". pattern
			call setline(mline[0],g:linelist[mline[0]-a:startline])
		endfor

		redraw

		return charget
	"endtry
endfunction

let b:subjump_matchlist = []
let b:subjump_matchlist_pos = -1

function! LineJumpForwardMove()
	if g:LineJumpSelectMethod ==2 || (g:LineJumpSelectMethod == 3 && g:LineJumpSmartSelectMethod == 1)
	else
		return
	endif
	if b:subjump_matchlist_pos != -1
		let b:subjump_matchlist_pos += 1
		if b:subjump_matchlist_pos == len(b:subjump_matchlist)
			let b:subjump_matchlist_pos = 0
		endif
	endif
	let linefound = b:subjump_matchlist[b:subjump_matchlist_pos][0]
	let newpos = getpos('.')
	let newpos[2] = b:subjump_matchlist[b:subjump_matchlist_pos][1] + 1
	let newpos[1] = linefound
	call setpos('.', newpos)
endfunction

function! LineJumpBackwardMove()
	if g:LineJumpSelectMethod ==2 || (g:LineJumpSelectMethod == 3 && g:LineJumpSmartSelectMethod == 1)
	else
		return
	endif
	if b:subjump_matchlist_pos != -1
		if b:subjump_matchlist_pos == 0
			let b:subjump_matchlist_pos = len(b:subjump_matchlist) - 1
		else
			let b:subjump_matchlist_pos -= 1
		endif
	endif
	let linefound = b:subjump_matchlist[b:subjump_matchlist_pos][0]
	let newpos = getpos('.')
	let newpos[2] = b:subjump_matchlist[b:subjump_matchlist_pos][1] + 1
	let newpos[1] = linefound
	call setpos('.', newpos)
endfunction

function! LineJumpForwardSelect()
	let startline = line(".")
	let endline = line("w$")
	call LineJumpRange(startline, endline)
endfunction

function! LineJumpBackwardSelect()
	let startline = line("w0")
	let endline = line(".")
	call LineJumpRange(startline, endline)
endfunction

let g:LineJumpSameCharLines = 4

"return a list indicate sub select pos
"[line, column, char]
function! FindSameChars(selectlist)
	"first, find the longest chars that make the lines of
	"matching not more than g:LineJumpSameCharLines
	let scanPos = 0
	let scanChars = 1
	while 9
		let match = 0
		for line in selectlist
			if matchstr

		endfor
	endwhile

	"than, find each lines start character(highlight character)
	"
endfunction

"skip the same head characters in current line, search forward
function! LineJumpForwardSubSelect()

endfunction

"skip the same head character in current line, search backward
function! LineJumpBackwardSubSelect()

endfunction

function! LineJumpPage()
	let startline = line("w0")
	let endline = line("w$")
	call LineJumpRange(startline, endline)
endfunction

function! LineJumpRange(startline, endline)

	call LineJumpLoadColor(s:target_select_defaults,s:LineJumpSelectGroup)
	call LineJumpLoadColor(s:target_hl_defaults,s:LineJumpHiGroup)

	let s:LineJumpCharacterDict = {}
	let old_modifiable = &modifiable
    "setlocal buftype=nofile
    setlocal modifiable

	let old_undolevels = &undolevels
	set undolevels=-1

	let startline = a:startline
	let endline = a:endline

	try
		let g:linelist = getline(startline, endline)
		let lineindex = startline
		let hl_coords = []
		for line in g:linelist
			let pos = match(line, '\w')
			if pos != -1
				let c = matchstr(line,'\w')
				"echo "c" . c
				let pos_list = [lineindex, pos]
				if !has_key(s:LineJumpCharacterDict,c)
					let s:LineJumpCharacterDict[c] = []
				endif
				call add(s:LineJumpCharacterDict[c],pos_list)
				"call add(hl_coords, '\%' . lineindex . 'l\%' . (pos+1) . 'c')
				call add(hl_coords, '\%' . lineindex . 'l\%' . (pos+1) . 'c')
			endif
			let lineindex += 1
		endfor

		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)

		redraw

		"XXX
		let charget = '#'
		while 9
			let key = getchar()
			let char = nr2char(key)
			"echo "char " . char
			"TODO handle error key 
			if has_key(s:LineJumpCharacterDict,char)
				let charget = char
				break
			endif
			"echo "linejump " . linejump
		endwhile
	catch
	finally
		if exists('target_hl_id')
			call matchdelete(target_hl_id)
		endif

		redraw
	endtry

	"see if there more than one match line
	let matchlinelist = s:LineJumpCharacterDict[charget]
	echo len(matchlinelist)
	if len(matchlinelist) == 1
		let linefound = matchlinelist[0][0]
		let newpos = getpos('.')
		let newpos[2] = matchlinelist[0][1] + 1
		let newpos[1] = linefound
		call setpos('.', newpos)
	else
		if g:LineJumpSelectMethod == 0
			call LineJumpSelectMethodByNumberAlpha(matchlinelist, startline,charget)
		elseif g:LineJumpSelectMethod == 2
			"select by LineJumpForwardMove(), LineJumpPageBackward()
			let linefound = matchlinelist[0][0]
			let newpos = getpos('.')
			let newpos[2] = matchlinelist[0][1] + 1
			let newpos[1] = linefound
			call setpos('.', newpos)
			let b:subjump_matchlist = matchlinelist[:]
			let b:subjump_matchlist_pos = 0
		endif
	endif

	"let bufname = bufname('%')
	""echo bufname
	"for pattern in g:line_jump_post_action_priority
		""echo "pattern:". pattern
		"if match(bufname, pattern,0) != -1
		""if match(bufname, ".*",0) != -1
			""echo "match pattern:". pattern
			"execute "" . g:line_jump_post_action[pattern]
			"break
		"endif
	"endfor

	let &undolevels = old_undolevels
	"unlet old_undolevels

	if old_modifiable == 0
		setlocal nomodifiable
	endif
endfunction

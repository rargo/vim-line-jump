let s:alpha_forward_list = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
let s:alpha_line_map = {'0':0,'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9,'a':10,'b':11,'c':12,'d':13,'e':14,'f':15,'g':16,'h':17,'i':18,'j':19,'k':20,'l':21,'m':22,'n':23,'o':24,'p':25,'q':26,'r':27,'s':28,'t':29,'u':30,'v':31,'w':32,'x':33,'y':34,'z':35,'A':36,'B':37,'C':38,'D':39,'E':40,'F':41,'G':42,'H':43,'I':44,'J':45,'K':46,'L':47,'M':48,'N':49,'O':50,'P':51,'Q':52,'R':53,'S':54,'T':55,'U':56,'V':57,'W':58,'X':59,'Y':60,'Z':61}
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

call LineJumpLoadColor(s:target_select_defaults,s:LineJumpSelectGroup)
call LineJumpLoadColor(s:target_hl_defaults,s:LineJumpHiGroup)

"
let g:line_jump_post_action = {'__Tagbar__': "normal w",'NERD_tree_\d\+':"call Linejumpfirstword()", '.*':"normal zz"}
let g:line_jump_post_action_priority = ['__Tagbar__', 'NERD_tree_\d\+', '*']

function! Linejumpstart()
	let old_modifiable = &modifiable
    "setlocal buftype=nofile
    setlocal modifiable

	let old_undolevels = &undolevels
	set undolevels=-1

	let hl_coords = []
	let startline = line("w0")
	let endline = line("w$")
	let g:linelist = getline(startline, endline)
	let linelist_replace = []
	let i = 0
	for line in g:linelist
		"make new line
		if i % 2 == 0
			let newline = s:alpha_forward_list[i] . "  " . line
		else
			"let newline = " " . s:alpha_forward_list[i] . " " . line
			let newline = s:alpha_forward_list[i] . "  " . line
		endif
		call add(hl_coords, '\%' . (startline+i) . 'l\%' . 1 . 'c')
		call add(linelist_replace, newline)
		let i += 1
	endfor

	call setline(startline, linelist_replace)

	let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 1)

	redraw

	let key = getchar()
	let char = nr2char(key)
	"echo "char " . char
	let linejump = get(s:alpha_line_map,char,10000)
	"echo "linejump " . linejump
	if linejump != 10000
		let pos = getpos('.')
		let pos[2] = 0
		let pos[1] = linejump + startline
		call setpos('.', pos)
	endif
	call setline(startline, g:linelist)

	if exists('target_hl_id')
		call matchdelete(target_hl_id)
	endif

	let bufname = bufname('%')
	echo bufname
	for pattern in g:line_jump_post_action_priority
		"echo "pattern:". pattern
		if match(bufname, pattern,0) != -1
		"if match(bufname, ".*",0) != -1
			"echo "match pattern:". pattern
			execute "" . g:line_jump_post_action[pattern]
			break
		endif
	endfor

	let &undolevels = old_undolevels
	"unlet old_undolevels

	if old_modifiable == 0
		setlocal nomodifiable
	endif
endfunction

function! Linejumpfirstword()
	let pos = getpos('.')
	let first_word_pos = match(getline('.'), '\w\+')
	if first_word_pos != -1
		let pos[2] = first_word_pos + 1
		call setpos('.',pos)
	endif
endfunction

"let g:LineJumpMethod = 0

"function! LineJumpPageBackward()
	"let old_modifiable = &modifiable
    ""setlocal buftype=nofile
    "setlocal modifiable

	"let old_undolevels = &undolevels
	"set undolevels=-1

	"let &undolevels = old_undolevels
	""unlet old_undolevels

	"if old_modifiable == 0
		"setlocal nomodifiable
	"endif
"endfunction

"function! LineJumpForward()
	"let old_modifiable = &modifiable
    ""setlocal buftype=nofile
    "setlocal modifiable

	"let old_undolevels = &undolevels
	"set undolevels=-1

	"let &undolevels = old_undolevels
	""unlet old_undolevels

	"if old_modifiable == 0
		"setlocal nomodifiable
	"endif
"endfunction

"{'a':[[0,1], [3,2]], 'b':[[1,2],[5,4]]}

"select
"	0: select by press number and alpha
"	1: select by "j,k,h,l,m"
let g:LineJumpSelectMethod = 1

let s:LineJumpCharacterDict = {}
function! LineJumpSelectMethodByMotion(matchlinelist)
		let hl_coords = []
		for mline in a:matchlinelist
			call add(hl_coords, '\%' . mline[0] . 'l\%' . (mline[1]+1) . 'c')
		endfor

		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
		redraw

		let charget = '#'
		let current_index = 0
		let max_index = len(a:matchlinelist) - 1
		let newpos = getpos('.')
		let newpos[1] = a:matchlinelist[current_index][0] "line number
		let newpos[2] = a:matchlinelist[current_index][1] + 1 "column number
		call setpos('.', newpos)
		let select_coord = []
		call add(select_coord, '\%' . newpos[1] . 'l\%' . newpos[2] . 'c')
		let target_select_id = matchadd(s:LineJumpSelectGroup, join(select_coord, '\|'), 200)
		redraw
		while 9
			let key = getchar()
			let char = nr2char(key)
			if char == 'j'
				let  current_index += 1
				if current_index > max_index
					let current_index = 0
				endif
			elseif char == 'k'
				let  current_index -= 1
				if current_index < 0
					let current_index = max_index
				endif
			elseif char == 'm'
				let  current_index = max_index/2
			elseif char == 'l'
				let  current_index = max_index
			elseif char == 'h'
				let  current_index = 0
			else
				break
			endif
			let newpos = getpos('.')
			let newpos[1] = a:matchlinelist[current_index][0] "line number
			let newpos[2] = a:matchlinelist[current_index][1] + 1 "column number
			call setpos('.', newpos)
			if exists('target_select_id')
				call matchdelete(target_select_id)
			endif
			let select_coord = []
			call add(select_coord, '\%' . newpos[1] . 'l\%' . newpos[2] . 'c')
			let target_select_id = matchadd(s:LineJumpSelectGroup, join(select_coord, '\|'), 200)
			redraw
			"echo "char " . char
		endwhile

		if exists('target_select_id')
			call matchdelete(target_select_id)
		endif

		if exists('target_hl_id')
			call matchdelete(target_hl_id)
		endif
endfunction

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
			let alpha_use_dict[s:alpha_forward_list[ki]] = mline[0]
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
		let newpos[2] = 0
		let newpos[1] = linefound
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
	"endtry
endfunction

function! LineJumpPage()

	let s:LineJumpCharacterDict = {}
	let old_modifiable = &modifiable
    "setlocal buftype=nofile
    setlocal modifiable

	let old_undolevels = &undolevels
	set undolevels=-1

	try
		let startline = line("w0")
		let endline = line("w$")
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
	else
		if g:LineJumpSelectMethod == 0
			call LineJumpSelectMethodByNumberAlpha(matchlinelist, startline,charget)
		else
			call LineJumpSelectMethodByMotion(matchlinelist)
		endif
	endif

	let bufname = bufname('%')
	"echo bufname
	for pattern in g:line_jump_post_action_priority
		"echo "pattern:". pattern
		if match(bufname, pattern,0) != -1
		"if match(bufname, ".*",0) != -1
			"echo "match pattern:". pattern
			execute "" . g:line_jump_post_action[pattern]
			break
		endif
	endfor

	let &undolevels = old_undolevels
	"unlet old_undolevels

	if old_modifiable == 0
		setlocal nomodifiable
	endif
endfunction

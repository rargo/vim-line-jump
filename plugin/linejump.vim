let s:alpha_forward_list = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
let s:alpha_line_map = {'0':0,'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9,'a':10,'b':11,'c':12,'d':13,'e':14,'f':15,'g':16,'h':17,'i':18,'j':19,'k':20,'l':21,'m':22,'n':23,'o':24,'p':25,'q':26,'r':27,'s':28,'t':29,'u':30,'v':31,'w':32,'x':33,'y':34,'z':35,'A':36,'B':37,'C':38,'D':39,'E':40,'F':41,'G':42,'H':43,'I':44,'J':45,'K':46,'L':47,'M':48,'N':49,'O':50,'P':51,'Q':52,'R':53,'S':54,'T':55,'U':56,'V':57,'W':58,'X':59,'Y':60,'Z':61}
"let g:linelist = []

"borrow from easymotion
let s:target_hl_defaults = {
\   'gui'     : ['NONE', '#ff0000' , 'bold']
\ , 'cterm256': ['NONE', '196'     , 'bold']
\ , 'cterm'   : ['NONE', 'red'     , 'bold']
\ }

" Reset highlighting after loading a new color scheme {{{
autocmd ColorScheme * call LineJumpLoadColor(s:target_hl_defaults)


let s:LineJumpHiGroup = "LineJumpHiGroup"

call LineJumpLoadColor(s:target_hl_defaults)

"load color for linejump
function! LineJumpLoadColor(colors)
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
		execute printf('hi default %s %s %s', "LineJumpHiGroupDefault", guihl, ctermhl)
		" No colors are defined for this group, link to defaults
		execute printf('hi default link %s %s', s:LineJumpHiGroup, "LineJumpHiGroupDefault")
endfunction

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

let s:LineJumpCharacterDict = {}
function! LineJumpPage()

	let s:LineJumpCharacterDict = {}
	let old_modifiable = &modifiable
    "setlocal buftype=nofile
    setlocal modifiable

	let old_undolevels = &undolevels
	set undolevels=-1

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
			call add(hl_coords, '\%' . lineindex . 'l\%' . (pos+1) . 'c')
		endif
		let lineindex += 1
	endfor

	let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 1)

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

	if exists('target_hl_id')
		call matchdelete(target_hl_id)
	endif

	redraw

	"see if there more than one match line
	let linefound = 10000
	let matchlinelist = s:LineJumpCharacterDict[charget]
	echo len(matchlinelist)
	if len(matchlinelist) == 1
		let linefound = matchlinelist[0][0]
	else
		let ki = 0
		let alpha_use_dict = {}
		let hl_coords = []
		let ki = 0
		for mline in matchlinelist
			let line = g:linelist[mline[0]-startline]
			let linereplace = substitute(line,charget,s:alpha_forward_list[ki],"")
			call setline(mline[0],linereplace)
			call add(hl_coords, '\%' . mline[0] . 'l\%' . (mline[1]+1) . 'c')
			let alpha_use_dict[s:alpha_forward_list[ki]] = mline[0]
			let ki += 1
		endfor
		echo s:alpha_forward_list

		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 1)
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

		if exists('target_hl_id')
			call matchdelete(target_hl_id)
		endif

		"restore line
		for mline in matchlinelist
			"echo "match pattern:". pattern
			call setline(mline[0],g:linelist[mline[0]-startline])
		endfor

		redraw
	endif

	if linefound != 10000
		let newpos = getpos('.')
		let newpos[2] = 0
		let newpos[1] = linefound
		call setpos('.', newpos)
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

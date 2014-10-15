"linejump, jump quickly by select line's first alpha
"rargo.m@gmail.com

"g:LineJumpSelectMethod, define sub select way
"	0: sub select by LineJumpMoveForward(), LineJumpMoveBackward()
"		need to map these two functions to some key
"	1: sub select by press number and alpha
if !exists("g:LineJumpSelectMethod")
	let g:LineJumpSelectMethod = 0
endif

"if you want to select line only visable in the window, set it to 1
"default as select will search the whole buffer
"only valid when g:LineJumpSelectMethod == 0
if !exists("g:LineJumpSelectInVisable")
	let g:LineJumpSelectInVisable = 0
endif

"highlight in LineJump moves, default as off
if !exists("g:LineJumpMoveHighlight")
	let g:LineJumpMoveHighlight = 0
endif

let b:LineJumpCharacterDict = {}

let s:alpha_forward_list = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9']

"if your monitor has more than 62 lines,
"Hi, tuhao, can we be friends?
let s:alpha_line_map = {'a':0,'b':1,'c':2,'d':3,'e':4,'f':5,'g':6,'h':7,'i':8,'j':9,'k':10,'l':11,'m':12,'n':13,'o':14,'p':15,'q':16,'r':17,'s':18,'t':19,'u':20,'v':21,'w':22,'x':23,'y':24,'z':25,'A':26,'B':27,'C':28,'D':29,'E':30,'F':31,'G':32,'H':33,'I':34,'J':35,'K':36,'L':37,'M':38,'N':39,'O':40,'P':41,'Q':42,'R':43,'S':44,'T':45,'U':46,'V':47,'W':48,'X':49,'Y':50,'Z':51,'0':52,'1':53,'2':54,'3':55,'4':56,'5':57,'6':58,'7':59,'8':60,'9':61}
"let s:linelist = []

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

"let g:line_jump_post_action = {'__Tagbar__': "normal w",'NERD_tree_\d\+':"call Linejumpfirstword()", '.*':"normal zz"}
"let g:line_jump_post_action_priority = ['__Tagbar__', 'NERD_tree_\d\+', '*']

"function! Linejumpfirstword()
	"let pos = getpos('.')
	"let first_word_pos = match(getline('.'), '\w\+')
	"if first_word_pos != -1
		"let pos[2] = first_word_pos + 1
		"call setpos('.',pos)
	"endif
"endfunction

function! LineJumpPeekCharTimeout(milli) 
    " non-consuming key-wait with timeout 
    let k=a:milli 
    while k > 0 && getchar(1) == 0 
        sleep 50m 
        let k = k - 50
    endwh 
    return getchar(1) 
endfun 

let b:subjump_matchlist = []
let b:subjump_forward = -1

function! LineJumpMoveTop()
	if g:LineJumpSelectMethod != 0
		return
	endif

	if len(b:subjump_matchlist) == 0
		return
	endif

	if g:LineJumpMoveHighlight != 0
		"highlight positions
		let hl_coords = []
		for l in b:subjump_matchlist
			call add(hl_coords, '\%' . l[0] . 'l\%' . (l[1]+1) . 'c')
		endfor
		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
	endif

	"try to find next match position, base on current position
	let pos = getpos('.')
	let pos[2] = b:subjump_matchlist[0][1] + 1
	let pos[1] = b:subjump_matchlist[0][0]
	call setpos('.', pos)

	if g:LineJumpMoveHighlight != 0
		let hl_coords = []
		call add(hl_coords, '\%' . pos[1] . 'l\%' . (pos[2]) . 'c')
		let target_hl_select_id = matchadd(s:LineJumpSelectGroup, join(hl_coords, '\|'), 100)
		redraw

		call LineJumpPeekCharTimeout(300)
		call matchdelete(target_hl_id)
		call matchdelete(target_hl_select_id)
		redraw
	endif
endfunction

function! LineJumpMoveBottom()
	if g:LineJumpSelectMethod != 0
		return
	endif

	if len(b:subjump_matchlist) == 0
		return
	endif

	if g:LineJumpMoveHighlight != 0
		"highlight positions
		let hl_coords = []
		for l in b:subjump_matchlist
			call add(hl_coords, '\%' . l[0] . 'l\%' . (l[1]+1) . 'c')
		endfor
		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
	endif

	"try to find next match position, base on current position
	let pos = getpos('.')
	let pos[2] = b:subjump_matchlist[len(b:subjump_matchlist)-1][1] + 1
	let pos[1] = b:subjump_matchlist[len(b:subjump_matchlist)-1][0]
	call setpos('.', pos)

	if g:LineJumpMoveHighlight != 0
		let hl_coords = []
		call add(hl_coords, '\%' . pos[1] . 'l\%' . (pos[2]) . 'c')
		let target_hl_select_id = matchadd(s:LineJumpSelectGroup, join(hl_coords, '\|'), 100)
		redraw

		call LineJumpPeekCharTimeout(300)
		call matchdelete(target_hl_id)
		call matchdelete(target_hl_select_id)
		redraw
	endif
endfunction

function! LineJumpMoveMiddle()
	if g:LineJumpSelectMethod != 0
		return
	endif

	if len(b:subjump_matchlist) == 0
		return
	endif

	if g:LineJumpMoveHighlight != 0
		"highlight positions
		let hl_coords = []
		for l in b:subjump_matchlist
			call add(hl_coords, '\%' . l[0] . 'l\%' . (l[1]+1) . 'c')
		endfor
		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
	endif

	"try to find next match position, base on current position
	let pos = getpos('.')
	let pos[2] = b:subjump_matchlist[len(b:subjump_matchlist)/2][1] + 1
	let pos[1] = b:subjump_matchlist[len(b:subjump_matchlist)/2][0]
	call setpos('.', pos)

	if g:LineJumpMoveHighlight != 0
		let hl_coords = []
		call add(hl_coords, '\%' . pos[1] . 'l\%' . (pos[2]) . 'c')
		let target_hl_select_id = matchadd(s:LineJumpSelectGroup, join(hl_coords, '\|'), 100)
		redraw

		call LineJumpPeekCharTimeout(300)
		call matchdelete(target_hl_id)
		call matchdelete(target_hl_select_id)
		redraw
	endif
endfunction

function! LineJumpMoveForward()
	if g:LineJumpSelectMethod != 0
		return
	endif

	if len(b:subjump_matchlist) == 0
		return
	endif

	if g:LineJumpMoveHighlight != 0
		"highlight positions
		let hl_coords = []
		for l in b:subjump_matchlist
			call add(hl_coords, '\%' . l[0] . 'l\%' . (l[1]+1) . 'c')
		endfor
		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
	endif

	"try to find next match position, base on current position
	let pos = getpos('.')
	let line =  pos[1]

	let i = 0
	for l in b:subjump_matchlist
		if b:subjump_forward != 0
			"forward jump
			if b:subjump_matchlist[i][0] > line
				break
			endif
		else
			"backward jump
			if b:subjump_matchlist[i][0] < line
				break
			endif
		endif
		let i = i + 1
	endfor
	if i == len(b:subjump_matchlist)
		let i = 0
	endif

	let pos[2] = b:subjump_matchlist[i][1] + 1
	let pos[1] = b:subjump_matchlist[i][0]
	call setpos('.', pos)

	if g:LineJumpMoveHighlight != 0
		let hl_coords = []
		call add(hl_coords, '\%' . pos[1] . 'l\%' . (pos[2]) . 'c')
		let target_hl_select_id = matchadd(s:LineJumpSelectGroup, join(hl_coords, '\|'), 100)
		redraw

		call LineJumpPeekCharTimeout(300)
		call matchdelete(target_hl_id)
		call matchdelete(target_hl_select_id)
		redraw
	endif
endfunction

function! LineJumpMoveBackward()
	if g:LineJumpSelectMethod != 0
		return
	endif

	if len(b:subjump_matchlist) == 0
		return
	endif
	
	if g:LineJumpMoveHighlight != 0
		"highlight positions
		let hl_coords = []
		for l in b:subjump_matchlist
			call add(hl_coords, '\%' . l[0] . 'l\%' . (l[1]+1) . 'c')
		endfor
		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
		redraw
	endif

	"try to find prev match position, base on current position
	let pos = getpos('.')
	let line =  pos[1]

	let i = len(b:subjump_matchlist) - 1
	for l in b:subjump_matchlist
		if b:subjump_forward != 0
			if b:subjump_matchlist[i][0] < line
				break
			endif
		else
			if b:subjump_matchlist[i][0] > line
				break
			endif
		endif
		let i = i - 1
	endfor
	if i < 0
		let i = len(b:subjump_matchlist) - 1
	endif

	let pos[1] = b:subjump_matchlist[i][0]
	let pos[2] = b:subjump_matchlist[i][1] + 1
	call setpos('.', pos)

	if g:LineJumpMoveHighlight != 0
		let hl_coords = []
		call add(hl_coords, '\%' . pos[1] . 'l\%' . (pos[2]) . 'c')
		let target_hl_select_id = matchadd(s:LineJumpSelectGroup, join(hl_coords, '\|'), 100)
		redraw

		call LineJumpPeekCharTimeout(300)
		call matchdelete(target_hl_id)
		call matchdelete(target_hl_select_id)
		redraw
	endif
endfunction

function! LineJumpSelectForward()
	if g:LineJumpSelectMethod == 0 && g:LineJumpSelectInVisable == 0
		let endline = line("$")
	else
		let endline = line("w$")
	endif
	let startline = line(".") + 1
	if startline > endline
		return
	endif
	call LineJumpSelect(startline, endline, 1)
endfunction

function! LineJumpSelectBackward()
	if g:LineJumpSelectMethod == 0 && g:LineJumpSelectInVisable == 0
		let startline = 1
	else
		let startline = line("w0")
	endif
	let endline = line(".") - 1
	if endline < startline
		return
	endif
	call LineJumpSelect(startline, endline, 0)
endfunction

"let g:SameCharLines = 4

"let g:TestLine = ["v", "vimaa1","vimab2k","vimac3","vimad4","vim","vimb","vimb","vimb","vimc1","vimc2","vimc3","vimc4a","vimc5b"]

""return a list indicate sub select pos
""[line, column, char]
"function! FindSameChars(selectlist)
	""first, find the longest chars that make the lines of
	""matching not more than g:LineJumpSameCharLines
	"let selectlist_len = len(a:selectlist)
	"let scanlist = range(selectlist_len)
	"let i = 0
	"for l in scanlist
		"let scanlist[i] = []
		"let i = i+1
	"endfor

	""stop when scanlist all index fill
	"let scanColumn = 0
	"while 9
		""fill the index in scanlist:
		""1. when the line has no more character
		""2. when no sequence line has the same character more than g:SameCharLines
		"let i = 0
		"for s in scanlist
			"if empty(s)
				"break
			"endif
			"let i = i+1
		"endfor

		"if i == selectlist_len
			""echo "@@@@@@@@@@list all scan finish@@@@@@@@@@"
			""echo scanlist
			"break
		"endif

		"let scanIndex = i
		"let lastIndex = -1
		"let startI = scanIndex
		"let sameCharCount = 1
		"let lastChar = ''
		"let restartScan = 0
		""echo "=====start scan index: " . scanIndex . " column:" . scanColumn . "====="
		""echo "lastChar:" . lastChar
		"for i in range(scanIndex,selectlist_len-1)

			""skip already in scanlist
			"if !empty(scanlist[i])
				"""echo "skip " . i
				"continue
			"endif

			"let line = a:selectlist[i]
			"let char = line[scanColumn]
			"if len(line) == scanColumn + 1
				""add the line to scanlist
				"let newlist = [scanColumn,char]
				"let scanlist[i] = newlist[:]
				""echo "add line " . i . " to scanlist(line exhaust)"
				""echo "char " . char . " column:" . scanColumn

				"let restartScan = 1
				"break

			"else
				"if char == lastChar
					"let sameCharCount = sameCharCount + 1
					""echo "sameCharCount: " . sameCharCount . "(add), line:" . i ", char:" . char . ", lastChar:" . lastChar
				"else
					"if lastChar != '' "not the first line compare the first line
						"if sameCharCount < g:SameCharLines
							""find some not match line, add it to scanlist
							""echo "sameCharCount: " . sameCharCount
							"for j in range(startI, i-1)
								"if !empty(scanlist[j])
									"continue
								"endif
								"let char = a:selectlist[j][scanColumn]
								"let newlist = [scanColumn,char]
								"let scanlist[j] = newlist[:]
								""echo "add line " . j . " to scanlist(diff)"
								""echo "char " . char . " column:" . scanColumn
							"endfor

							"let restartScan = 1
							"break
						"else
							"let lastChar = char
							"let startI = i "reset position
							"let sameCharCount = 1 "different char found, reset counter
						"endif
					"else
						"let lastChar = char
					"endif
				"endif
			"endif
			"let lastIndex = i
		"endfor

		"if restartScan == 0
			""add tail lines
			"if sameCharCount < g:SameCharLines
				"for j in range(startI, i)
					""echo "add line " . j . " to scanlist(tail lines)"
					"let char = line[scanColumn]
					"let newlist = [scanColumn,char]
					"let scanlist[j] = newlist[:]
					""echo "char " . char . " column:" . scanColumn
				"endfor
			"endif

			"let scanColumn = scanColumn + 1
		"endif
	"endwhile

	"return scanlist
"endfunction

"function! LJforward()
	"call LineJumpForwardSubSelect()
"endfunction

"function! LJbackward()
	"call LineJumpBackwardSubSelect()
"endfunction

""skip the same head characters in current line, search forward
"function! LineJumpForwardSubSelect()
	"let startline = line(".")
	"let endline = line("w$")
	"call LineJumpSubSelect(startline, endline)
"endfunction

""skip the same head character in current line, search backward
"function! LineJumpBackwardSubSelect()
	"let startline = line("w0")
	"let endline = line(".")
	"call LineJumpSubSelect(startline, endline)
"endfunction

"function! LineJumpSubSelect(startline, endline)
	"echo "LineJumpSubSelect"
	"call LineJumpLoadColor(s:target_select_defaults,s:LineJumpSelectGroup)
	"call LineJumpLoadColor(s:target_hl_defaults,s:LineJumpHiGroup)

	"let old_modifiable = &modifiable
    ""setlocal buftype=nofile
    "setlocal modifiable

	"let old_undolevels = &undolevels
	"set undolevels=-1

	"let startline = a:startline
	"let endline = a:endline

	"let s:linelist = getline(startline, endline)
	"let scanlist = FindSameChars(s:linelist)
	"echo scanlist
	"call getchar()
	"let lineindex = startline
	"let hl_coords = []
	"let i = 0
	"for l in scanlist
		"call add(hl_coords, '\%' . (i+startline) . 'l\%' . (l[0]+1) . 'c')
		"let i = i+1
	"endfor

	"let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)

	"redraw

	""XXX
	"let charget = '#'
	"while 9
		"let key = getchar()
		"let char = nr2char(key)
		"break
		""let i = 0
		""for l in scanlist
			""if char == l[1]
				""break
			""endif
			""let i = i+1
		""endfor
	"endwhile

	"if exists('target_hl_id')
		"call matchdelete(target_hl_id)
	"endif

	""let newpos = getpos('.')
	""let newpos[2] = scanlist[i][0] + 1
	""let newpos[1] = startline+i
	""call setpos('.', newpos)

	"let &undolevels = old_undolevels
	""unlet old_undolevels

	"if old_modifiable == 0
		"setlocal nomodifiable
	"endif
"endfunction

function! LineJumpPage()
	let startline = line("w0")
	let endline = line("w$")
	call LineJumpSelect(startline, endline, 0)
"function! LineJumpPage()
	"let startline = line("w0")
	"let endline = line("w$")
	"call LineJumpSelect(startline, endline)
"endfunction
endfunction

function! LineJumpSelect(startline, endline, forward)

	call LineJumpLoadColor(s:target_select_defaults,s:LineJumpSelectGroup)
	call LineJumpLoadColor(s:target_hl_defaults,s:LineJumpHiGroup)

	let b:LineJumpCharacterDict = {}
	let old_modifiable = &modifiable
    "setlocal buftype=nofile
    setlocal modifiable

	let old_undolevels = &undolevels
	set undolevels=-1

	let startline = a:startline
	let endline = a:endline

	let s:linelist = getline(startline, endline)
	if g:LineJumpSelectMethod == 0 && a:forward == 0
		"backward jump, reverse list
		let savelinelist = s:linelist[:]
		let i = 0
		let lasti = len(savelinelist) - 1
		for l in savelinelist
			let s:linelist[i] = savelinelist[lasti - i]
			let i = i + 1
		endfor
		"echo s:linelist
		"call getchar()
	endif

	if g:LineJumpSelectMethod == 0 && a:forward == 0
		let lineindex = endline
	else
		let lineindex = startline
	endif
	let hl_coords = []
	for line in s:linelist
		let pos = match(line, '\w')
		if pos != -1
			let c = matchstr(line,'\w')
			"echo "c" . c
			let pos_list = [lineindex, pos]
			if !has_key(b:LineJumpCharacterDict,c)
				let b:LineJumpCharacterDict[c] = []
			endif
			call add(b:LineJumpCharacterDict[c],pos_list)
			"call add(hl_coords, '\%' . lineindex . 'l\%' . (pos+1) . 'c')
			call add(hl_coords, '\%' . lineindex . 'l\%' . (pos+1) . 'c')
		endif
		if g:LineJumpSelectMethod == 0 && a:forward == 0
			let lineindex -= 1
		else
			let lineindex += 1
		endif
	endfor

	if g:LineJumpSelectMethod == 1 && len(b:LineJumpCharacterDict) == 1
		"small optimuse, if only has one character, skip getkey
		let charget =  keys(b:LineJumpCharacterDict)[0]
	else
		let target_hl_id = matchadd(s:LineJumpHiGroup, join(hl_coords, '\|'), 100)
		redraw
		try
			let charget = '#'
			while 9
				let key = getchar()
				let char = nr2char(key)
				"echo "char " . char
				if has_key(b:LineJumpCharacterDict,char)
					let charget = char
					break
				endif
				"echo "linejump " . linejump
			endwhile
		catch
			"echo "Abort"
			let &undolevels = old_undolevels
			if old_modifiable == 0
				setlocal nomodifiable
			endif
			return
		finally
			call matchdelete(target_hl_id)
			redraw
		endtry
	endif

	"see if there more than one match line
	let matchlinelist = b:LineJumpCharacterDict[charget]
	"echo len(matchlinelist)
	if g:LineJumpSelectMethod == 1
		call LineJumpSelectByNumberAlpha(matchlinelist, startline,charget)
	elseif g:LineJumpSelectMethod == 0
		"select by LineJumpMoveForward(), LineJumpPageBackward()
		let linefound = matchlinelist[0][0]
		let newpos = getpos('.')
		let newpos[2] = matchlinelist[0][1] + 1
		let newpos[1] = linefound
		call setpos('.', newpos)
		let b:subjump_matchlist = matchlinelist[:]
		let b:subjump_forward = a:forward
	endif

	let &undolevels = old_undolevels

	if old_modifiable == 0
		setlocal nomodifiable
	endif
endfunction

function! LineJumpSelectByNumberAlpha(matchlinelist, startline, charget)

	if len(a:matchlinelist) == 1
		let newpos = getpos('.')
		let newpos[1] = a:matchlinelist[0][0]
		let newpos[2] = a:matchlinelist[0][1] + 1
		call setpos('.', newpos)
		return
	endif

	let ki = 0
	let alpha_use_dict = {}
	let hl_coords = []
	for mline in a:matchlinelist
		let line = s:linelist[mline[0]-a:startline]
		let linereplace = substitute(line,a:charget,s:alpha_forward_list[ki],"") 
		call setline(mline[0],linereplace)
		call add(hl_coords, '\%' . mline[0] . 'l\%' . (mline[1]+1) . 'c')
		let alpha_use_dict[s:alpha_forward_list[ki]] = mline
		let ki += 1
		if ki >= len(alpha_forward_list)
			break
		endif
	endfor

	let target_hl_id = matchadd(s:LineJumpSelectGroup, join(hl_coords, '\|'), 100)
	redraw

	try
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
	catch
	finally
		call matchdelete(target_hl_id)
		"restore line
		for mline in a:matchlinelist
			"echo "match pattern:". pattern
			call setline(mline[0],s:linelist[mline[0]-a:startline])
		endfor
		redraw
	endtry
endfunction

let g:alpha_forward_list = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
let g:alpha_line_map = {'0':0,'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9,'a':10,'b':11,'c':12,'d':13,'e':14,'f':15,'g':16,'h':17,'i':18,'j':19,'k':20,'l':21,'m':22,'n':23,'o':24,'p':25,'q':26,'r':27,'s':28,'t':29,'u':30,'v':31,'w':32,'x':33,'y':34,'z':35,'A':36,'B':37,'C':38,'D':39,'E':40,'F':41,'G':42,'H':43,'I':44,'J':45,'K':46,'L':47,'M':48,'N':49,'O':50,'P':51,'Q':52,'R':53,'S':54,'T':55,'U':56,'V':57,'W':58,'X':59,'Y':60,'Z':61}
"let g:linelist = []

"
let g:line_jump_post_action = {'__Tagbar__': "normal w",'NERD_tree_\d\+':"call Linejumpfirstword()", '.*':"normal zz"}
let g:line_jump_post_action_priority = ['__Tagbar__', 'NERD_tree_\d\+', '*']

function! Linejumpstart()
	let old_modifiable = &modifiable
    "setlocal buftype=nofile
    setlocal modifiable

	let old_undolevels = &undolevels
	set undolevels=-1

	let startline = line("w0")
	let endline = line("w$")
	let g:linelist = getline(startline, endline)
	let linelist_replace = []
	let i = 0
	for line in g:linelist
		"make new line
		if i % 2 == 0
			let newline = g:alpha_forward_list[i] . "  " . line
		else
			let newline = " " . g:alpha_forward_list[i] . " " . line
		endif
		call add(linelist_replace, newline)
		let i += 1
	endfor

	call setline(startline, linelist_replace)
	execute "redraw"

	let key = getchar()
	let char = nr2char(key)
	"echo "char " . char
	let linejump = get(g:alpha_line_map,char,10000)
	"echo "linejump " . linejump
	if linejump != 10000
		let pos = getpos('.')
		let pos[2] = 0
		let pos[1] = linejump + startline
		call setpos('.', pos)
	endif
	call setline(startline, g:linelist)

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


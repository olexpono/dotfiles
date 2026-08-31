let mapleader = ","
set expandtab
set shiftwidth=2
set tabstop=2
set scrolloff=2
set listchars=trail:·,extends:>,tab:▻\ ,precedes:<
set list
set clipboard=unnamed

let g:airline_theme = 'bubblegum'
let g:airline_section_b = ''
let g:airline_section_c = '%f'
let g:airline_section_y = ''
let g:airline_section_z = airline#section#create(['%l/%L:C%v'])

let g:ale_fix_on_save = 1
let g:ale_fixers = {
 \ 'javascript': ['eslint'],
 \ 'typescript': ['eslint']
 \ }

let g:syntastic_javascript_checkers = ['xo']
let g:syntastic_typescript_checkers = ['xo']

try
    colorscheme murphy
catch /^Vim\%((\a\+)\)\=:E185/
    color murphy
endtry

syn sync fromstart

if has("gui_running")
    set guioptions=egmt

    " This removes the Cmd-P binding from 'Print':
    macmenu &File.Print key=<nop>
    macmenu &Edit.Find.Find… key=<nop>
endif

" hi SpecialKey guifg=#313131
hi ExtraWhitespace ctermbg=233 ctermfg=darkmagenta guifg=tan guibg=black

set number
set nocursorcolumn
set termguicolors
" set colorcolumn=79
" let &colorcolumn="79,".join(range(120,999),",")
highlight ColorColumn ctermfg=231 ctermbg=0 guifg=#d5d5d5 guibg=#252226
highlight Normal ctermfg=231 ctermbg=0 guifg=#d5d5d5 guibg=#252226
highlight SignColumn ctermfg=12 ctermbg=235 ctermfg=yellow guibg=#1d1d1d guifg=#727272
highlight SignColumn ctermfg=12 ctermbg=235 ctermfg=yellow guibg=#1d1d1d guifg=#727272
" highlight Todo ctermbg=235 ctermfg=magenta guibg=#282828 guifg=#EE8855
highlight LineNr term=underline ctermfg=darkcyan ctermbg=0 guifg=#454b45 guibg=#1d1d1d
highlight String ctermfg=121 gui=none guifg=#96d456
highlight VertSplit cterm=reverse ctermfg=235 ctermbg=233 gui=none guifg=#333344 guibg=#282828
highlight StatusLine cterm=bold ctermfg=230 ctermbg=238 gui=none guifg=#a5a8f2 guibg=#333344
highlight StatusLineNC ctermfg=103 ctermbg=235 guifg=#a4a2b2 guibg=#333344
highlight Search term=reverse ctermfg=1 ctermbg=237 guibg=#7aaa50 guifg=#121212
highlight Directory term=bold ctermfg=11 guifg=#f09865
highlight jsRegexpGroup term=bold ctermfg=11 guifg=#f09865
highlight jsRegexpString term=bold ctermfg=11 guifg=#f09865
highlight Cursor guibg=#eeeeee guifg=#357095
highlight ErrorMsg term=standout ctermfg=0 ctermbg=4 guifg=#f3f3f3 guibg=coral3
highlight Comment guifg=#da75aa ctermfg=221
highlight Special ctermfg=2 ctermfg=yellow guifg=#EDD56C
highlight Statement ctermfg=2 ctermfg=yellow guifg=#EDD56C
highlight Identifier ctermfg=yellow guifg=#FBC496 ctermfg=darkred
highlight markdownCode guifg=#9598f2 ctermfg=magenta
highlight typescriptReserved ctermfg=45 guifg=#85b5d5
highlight CocError ctermfg=209 guifg=#ff875f
highlight CocHintSign ctermfg=141 guifg=#af87df
highlight CocErrorVirtualText ctermfg=12 ctermbg=233 guifg=#ff44aa guibg=#222222

autocmd! GUIEnter * set vb t_vb=

" disable syntastic warning-level
let g:syntastic_quiet_messages = { "level": "warnings" }

set noswapfile
set guifont=Native:h14.5
au BufNewFile,BufRead *.block set filetype=html
au BufNewFile,BufRead *.page set filetype=html
au BufNewFile,BufRead *.list set filetype=html
au BufNewFile,BufRead *.item set filetype=html
au BufNewFile,BufRead *.ejs set filetype=html
au BufNewFile,BufRead *.js.ejs set filetype=javascript
au BufNewFile,BufRead .tmux.conf set filetype=tmux
au BufRead,BufNewFile *.es6 set filetype=javascript
au BufRead,BufNewFile *.prisma set filetype=graphql
au BufRead,BufNewFile *.ttx set filetype=xml

autocmd FileType less setlocal shiftwidth=2 tabstop=2
autocmd FileType css setlocal shiftwidth=2 tabstop=2
" autocmd BufWritePre *.tsx Prettier
" autocmd BufWritePre *.ts Prettier
" autocmd BufWritePre *.vue Prettier

function! TwoSpaceTabs()
  setlocal shiftwidth=2 tabstop=2
endfunction
function! FourSpaceTabs()
  setlocal shiftwidth=4 tabstop=4
endfunction

autocmd FileType python call FourSpaceTabs()
autocmd FileType javascript call TwoSpaceTabs()
" autocmd FileType css, less call TwoSpaceTabs()
" au filetypedetect FileType python, javascript call FourSpaceTabs()
"

" SESSIONS
function! MkSession()
  let b:sessiondir = getcwd()
  exe "SaveSession " . b:sessiondir
endfunction
function! LdSession()
  if argc() == 0
    let b:sessiondir = getcwd()
    exe "OpenSession! " . b:sessiondir
  endif
endfunction

let g:session_autosave="yes"
let g:session_autoload="no"

au VimLeave * :call MkSession()
au VimEnter * nested :call LdSession()

" KEYBINDINGS

:inoremap kj <esc>
:inoremap jk <esc>
map <D-s> :w<CR>
nmap <D-s> :w<CR>

imap %V* <Esc>:w<CR>
nmap %V* :w<CR>


:nmap <C-q> :syn sync fromstart<CR>
:nmap ci< T>vt<c
:nmap <silent> cp "_ciw<C-R>"<Esc>
:imap <C-e> <C-y>,
:imap <C-t> <return>top: 0;<return>right: 0;<return>bottom: 0;<return>left: 0;
:inoremap <C-x> <C-y>k
:nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
:map <C-\> :NERDTreeToggle<CR>
:imap <C-\> <C-O>:NERDTreeToggle<CR>
:nmap <C-\> <C-O>:NERDTreeToggle<CR>
map <leader>. :NERDTreeToggle<CR>
:map <C-L> :NERDTreeToggle<CR>
:imap <C-L> <C-O>:NERDTreeToggle<CR>

" Coc
:map <C-]> <Plug>(coc-definition)
" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>


function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Formatting selected code.
xmap <leader>f  :CocCommand eslint.executeAutofix<CR>
nmap <leader>f  :CocCommand eslint.executeAutofix<CR>

if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

:nmap <D-f> :Ack<space>
:nmap <D-F> :Ack<space>
:nmap <Meta-F> :Ack<space>

:map <leader>o :source ~/.config/nvim/init.vim<CR>:source ~/.config/nvim/init.after.vim<CR>
:map <leader>m :qall<CR>
:map <leader>s :w<CR>
:map <leader>v :vs<CR>
:map <leader>t :sp<CR>
:nmap H 0|
:nmap <leader>; m`b~``

:map <leader>g :Git blame<CR>
:map <D-p> :CtrlP<CR>
:map <C-p> :CtrlP<CR>
:nnoremap <leader>r :CtrlPClearAllCaches<CR>
let g:ctrlp_max_files=0
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|dist'
let g:vim_json_syntax_conceal = 0

:noremap <PageUp> <C-U>
:noremap <PageDown> <C-D>
:inoremap <PageUp> <C-O><C-U>
:inoremap <PageDown> <C-O><C-D>

:try
  :unmap <C-F>
:catch
:endtry

filetype plugin on

" Show syntax highlighting groups for word under cursor
nmap <F2> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Russn hakers
function! ChangeFileencoding()
  let encodings = ['cp1251', 'koi8-u', 'cp866']
  let prompt_encs = []
  let index = 0
  while index < len(encodings)
    call add(prompt_encs, index.'. '.encodings[index])
    let index = index + 1
  endwhile
  let choice = inputlist(prompt_encs)
  if choice >= 0 && choice < len(encodings)
    execute 'e ++enc='.encodings[choice].' %:p'
  endif
endf
nmap <F8> :call ChangeFileencoding()<CR>

" Control-P ignores node_modules
set wildignore+=*/node_modules/*

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Autocomplete with the first option if pop up menu is open.
" If it is not open, just do a regular tab.
" inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<TAB>"


"" NerdCommenter
nmap ÷ <plug>NERDCommenterToggle
vmap ÷ <plug>NERDCommenterToggle<CR>gv

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'



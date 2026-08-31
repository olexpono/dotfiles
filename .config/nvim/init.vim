let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'

if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'

Plug 'posva/vim-vue'
Plug 'xojs/vim-xo'
Plug 'mileszs/ack.vim'
Plug 'rhysd/vim-color-spring-night'
Plug 'csscomb/vim-csscomb'
Plug 'xolox/vim-misc'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'xolox/vim-session'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'yaegassy/coc-volar', { 'do': 'yarn install --frozen-lockfile' }
Plug 'yaegassy/coc-volar-tools', { 'do': 'yarn install --frozen-lockfile' }
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'christoomey/vim-tmux-navigator'
Plug 'airblade/vim-gitgutter'
Plug 'sheerun/vim-polyglot'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'rajasegar/vim-astro', {'branch': 'main'}
call plug#end()

source ~/.config/nvim/init.after.vim

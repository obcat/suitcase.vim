" Maintainer: obcat <obcat@icloud.com>
" License:    MIT License

augroup suitcase-cmdline-enter
  autocmd!
  autocmd CmdlineEnter * call suitcase#init(expand('<afile>'))
augroup suitcase-cmdline-changed
augroup END

" TODO: <Plug>(suitcase-c-p)
"       <Plug>(suitcase-c-n)
cmap <Plug>(suitcase-up)   <SID>(pre)<SID>(up)<SID>(post)
cmap <Plug>(suitcase-down) <SID>(pre)<SID>(down)<SID>(post)

cnoremap <expr> <SID>(up)   suitcase#arrow(getcmdtype(), 1)
cnoremap <expr> <SID>(down) suitcase#arrow(getcmdtype(), 0)
cnoremap <expr> <SID>(pre)  suitcase#delete_autocmd()
cnoremap <expr> <SID>(post) suitcase#define_autocmd()

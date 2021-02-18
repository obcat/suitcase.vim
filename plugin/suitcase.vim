" Maintainer: obcat <obcat@icloud.com>
" License:    MIT License

" TODO: <Plug>(suitcase-c-p)
"       <Plug>(suitcase-c-n)
cmap <Plug>(suitcase-up)   <SID>(pre)<SID>(up)<SID>(post)
cmap <Plug>(suitcase-down) <SID>(pre)<SID>(down)<SID>(post)

cnoremap <expr> <SID>(pre)  suitcase#switch_listener(0)
cnoremap <expr> <SID>(post) suitcase#switch_listener(1)
cnoremap <SID>(up)   <C-\>esuitcase#arrow(getcmdtype(), 1)<CR>
cnoremap <SID>(down) <C-\>esuitcase#arrow(getcmdtype(), 0)<CR>

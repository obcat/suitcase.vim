" Maintainer: obcat <obcat@icloud.com>
" License:    MIT License

" s:SPECIALS {{{
let s:SPECIALS = "\<BS>"
  \ . "\\|\<C-@>"
  \ . "\\|\<C-Left>"
  \ . "\\|\<C-Right>"
  \ . "\\|\<C-[>"
  \ . "\\|\<C-\>"
  \ . "\\|\<C-]>"
  \ . "\\|\<C-^>"
  \ . "\\|\<C-_>"
  \ . "\\|\<C-a>"
  \ . "\\|\<C-b>"
  \ . "\\|\<C-c>"
  \ . "\\|\<C-d>"
  \ . "\\|\<C-e>"
  \ . "\\|\<C-f>"
  \ . "\\|\<C-g>"
  \ . "\\|\<C-h>"
  \ . "\\|\<C-i>"
  \ . "\\|\<C-j>"
  \ . "\\|\<C-k>"
  \ . "\\|\<C-l>"
  \ . "\\|\<C-m>"
  \ . "\\|\<C-n>"
  \ . "\\|\<C-o>"
  \ . "\\|\<C-p>"
  \ . "\\|\<C-q>"
  \ . "\\|\<C-r>"
  \ . "\\|\<C-s>"
  \ . "\\|\<C-t>"
  \ . "\\|\<C-u>"
  \ . "\\|\<C-v>"
  \ . "\\|\<C-w>"
  \ . "\\|\<C-x>"
  \ . "\\|\<C-y>"
  \ . "\\|\<C-z>"
  \ . "\\|\<CR>"
  \ . "\\|\<Del>"
  \ . "\\|\<Down>"
  \ . "\\|\<End>"
  \ . "\\|\<Esc>"
  \ . "\\|\<Home>"
  \ . "\\|\<Insert>"
  \ . "\\|\<Left>"
  \ . "\\|\<LeftMouse>"
  \ . "\\|\<NL>"
  \ . "\\|\<PageDown>"
  \ . "\\|\<PageUp>"
  \ . "\\|\<Right>"
  \ . "\\|\<S-Down>"
  \ . "\\|\<S-Left>"
  \ . "\\|\<S-Right>"
  \ . "\\|\<S-Tab>"
  \ . "\\|\<S-Up>"
  \ . "\\|\<Tab>"
  \ . "\\|\<Up>"
" }}}
let s:phase = {
  \ '-': 0,
  \ '/': 0,
  \ ':': 0,
  \ '=': 0,
  \ '>': 0,
  \ '?': 0,
  \ '@': 0,
  \ }
let s:index = deepcopy(s:phase)

function suitcase#init(cmdtype) abort
  let s:phase[a:cmdtype] = 0
  let s:index[a:cmdtype] = 0
endfunction

function suitcase#go(up) abort
  let cmdtype = getcmdtype()
  if s:phase[cmdtype] == 0
    if cmdtype is '-'
      return ''
    endif
    if cmdtype is '?'
      let cmdtype = '/'
    endif
    let cmdline = getcmdline()
    let s:prefix = strpart(cmdline, 0, getcmdpos() - 1)
    let s:cmdlist = [cmdline] + s:histlist(cmdtype)
  endif
  let s:phase[cmdtype] = 1
  let ignorecase = get(g:, 'suitcase_ignorecase', &ignorecase)
    \ ? get(g:, 'suitcase_smartcase', &smartcase)
    \    ? s:prefix !~ '\u'
    \    : 1
    \ : 0
  let pattern = printf('^%s\V%s', ignorecase ? '\c' : '\C', escape(s:prefix, '\'))
  let segment = a:up
    \ ? s:cmdlist[(s:index[cmdtype] + 1):]
    \ : s:index[cmdtype] == 0
    \   ? []
    \   : s:cmdlist[:(s:index[cmdtype] - 1)] ->copy() ->reverse()
  let index = match(segment, pattern)
  if index == -1
    return ''
  endif
  let s:index[cmdtype] += (a:up ? +1 : -1) * (index + 1)
  return "\<C-e>\<C-u>" . substitute(s:cmdlist[s:index[cmdtype]], s:SPECIALS, "\<C-v>&", 'g')
endfunction

function suitcase#delete_autocmd() abort
  autocmd! suitcase-cmdline-changed CmdlineChanged
  return ''
endfunction

function suitcase#define_autocmd() abort
  augroup suitcase-cmdline-changed
    autocmd!
    autocmd CmdlineChanged * ++once let s:phase[expand('<afile>')] = 0
  augroup END
  return ''
endfunction

function s:histlist(histname) abort
  return range(histnr(a:histname), 0, -1)
    \ ->map('histget(a:histname, v:val)')
    \ ->filter('!empty(v:val)')
endfunction

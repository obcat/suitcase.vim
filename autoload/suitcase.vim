" Maintainer: obcat <obcat@icloud.com>
" License:    MIT License

let s:data = {}
for s:cmdtype in [':', '>', '/', '?', '@', '-', '=']
  let s:data[s:cmdtype] = {
    \ 'phase': 0,
    \ 'index': 0,
    \ 'history': [],
    \ 'pattern': '',
    \ }
endfor | unlet s:cmdtype

augroup suitcase-cmdline-enter
  autocmd!
  autocmd CmdlineEnter * let s:data[expand('<afile>')].phase = 0
  autocmd CmdlineEnter * let s:data[expand('<afile>')].index = 0
augroup END

function suitcase#switch_listener(on) abort
  augroup suitcase-cmdline-changed
    autocmd!
    if a:on
      autocmd CmdlineChanged * ++once let s:data[expand('<afile>')].phase = 0
    endif
  augroup END
  return ''
endfunction

function suitcase#arrow(cmdtype, up) abort
  let d = s:data[a:cmdtype]
  if d.phase == 0
    let cmdline = getcmdline()
    let d.history = [cmdline] + s:histget(a:cmdtype)
    let ignorecase = get(g:, 'suitcase_ignorecase', &ignorecase)
    let smartcase  = get(g:, 'suitcase_smartcase',  &smartcase)
    let prefix = strpart(cmdline, 0, getcmdpos() - 1)
    if ignorecase && smartcase && (prefix =~ '\u')
      let ignorecase = 0
    endif
    let d.pattern = printf('^%s\V%s', ignorecase ? '\c' : '\C', escape(prefix, '\'))
    let d.phase = 1
  endif
  let segment = a:up
    \ ? d.history[d.index :]
    \ : d.history[: d.index] ->reverse()
  let delta = match(segment, d.pattern, 1)
  if delta >= 1
    let d.index += (a:up ? +1 : -1) * delta
  endif
  return d.history[d.index]
endfunction

function s:histget(cmdtype) abort
  if a:cmdtype is '-'
    return []
  endif
  let histname = (a:cmdtype is '?') ? '/' : a:cmdtype
  return range(histnr(histname), 0, -1)
    \ ->map('histget(histname, v:val)')
    \ ->filter('!empty(v:val)')
endfunction

" Maintainer: obcat <obcat@icloud.com>
" License:    MIT License

let s:data = {}
for s:cmdtype in [':', '>', '/', '?', '@', '-', '=']
  let s:data[s:cmdtype] = {}
endfor | unlet s:cmdtype

function suitcase#init(cmdtype) abort
  let d = s:data[a:cmdtype]
  let d.phase = 0
  let d.index = 0
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
  if delta == -1
    return ''
  endif
  let d.index += (a:up ? +1 : -1) * delta
  return repeat(a:up ? "\<C-p>" : "\<C-n>", delta)
endfunction

function suitcase#delete_autocmd() abort
  autocmd! suitcase-cmdline-changed
  return ''
endfunction

function suitcase#define_autocmd() abort
  augroup suitcase-cmdline-changed
    autocmd!
    autocmd CmdlineChanged * ++once let s:data[expand('<afile>')].phase = 0
  augroup END
  return ''
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

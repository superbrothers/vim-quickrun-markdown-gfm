let s:static_dir = expand('<sfile>:p:h:h:h:h') . '/static/'
let s:css_files = ['github', 'highlight']
let s:js_files = ['highlight']
let s:stylesheet = ''
let s:javascript = ''

function! s:pack_resources_recur(html)
    if type(a:html) == type('')
        return a:html
    endif
    let l:attr_list = []
    for [attr_key, attr_val] in items(get(a:html, 'attr', {}))
        call add(l:attr_list, attr_key . '=' . '"' . substitute(attr_val, '"', '&quot;', 'g') . '"')
    endfor
    let l:attr = join(l:attr_list, ' ')
    let l:child = ''
    for child_val in get(a:html, 'child', [])
        let l:child .= s:pack_resources_recur(child_val)
        unlet child_val
    endfor
    return '<'
    \ . a:html.name
    \ . (l:attr == '' ? '' : ' ' . l:attr)
    \ . (l:child == '' ? '/>' : '>' . l:child . '</' . a:html.name . '>')
endfunction

function! s:pack_resources(data)
    return join(map(get(webapi#html#parse('<div>' . a:data . '</div>'), 'child', []), 's:pack_resources_recur(v:val)'), '')
endfunction

let s:hook = {
\   'name': 'markdown_gfm'
\ , 'kind': 'hook'
\ , 'config': {'enable': 1}
\ }

function! s:hook.on_ready(session, context)
    let s:stylesheet = join(map(copy(s:css_files), '"<style>" . join(readfile(s:static_dir . v:val . ".css"), "\n") . "</style>"'), "\n")
    let s:javascript = join(map(copy(s:js_files), '"<script>" . join(readfile(s:static_dir . v:val . ".js"), "\n") . "</script>"'), "\n")
endfunction

function! s:hook.on_output(session, context)
    let a:context.data = '<!doctype html>'
    \ . '<html lang="ja">'
    \ . '  <head>'
    \ . '    <meta charset="UTF-8"/>'
    \ . s:stylesheet . s:javascript
    \ . '  </head>'
    \ . '  <body>' . s:pack_resources(a:context.data) . '</body>'
    \ . '</html>'
endfunction

function! quickrun#hook#markdown_gfm#new()
    return deepcopy(s:hook)
endfunction

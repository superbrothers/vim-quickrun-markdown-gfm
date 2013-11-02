let s:static_dir = expand('<sfile>:p:h:h:h:h') . '/static/'
let s:css_files = ['github', 'highlight']
let s:js_files = ['highlight']
let s:stylesheet = ''
let s:javascript = ''

let s:hook = {
\   'name': 'markdown_gfm'
\ , 'kind': 'hook'
\ , 'config': {'enable': 1}
\ }

function! s:hook.on_ready(session, context)
    let l:css = map(s:css_files, '"<style>" . join(readfile(s:static_dir . v:val . ".css"), "\n") . "</style>"')
    let s:stylesheet = join(l:css, "\n")
    let l:js = map(s:js_files, '"<script>" . join(readfile(s:static_dir . v:val . ".js"), "\n") . "</script>"')
    let s:javascript = join(l:js, "\n")
endfunction

function! s:hook.on_output(session, context)
    let a:context.data = '<!doctype html>'
    \ . '<html lang="ja">'
    \ . '  <head>'
    \ . '    <meta charset="UTF-8"/>'
    \ . s:stylesheet . s:javascript
    \ . '  </head>'
    \ . '  <body>' . a:context.data . '</body>'
    \ . '</html>'
endfunction

function! quickrun#hook#markdown_gfm#new()
    return deepcopy(s:hook)
endfunction

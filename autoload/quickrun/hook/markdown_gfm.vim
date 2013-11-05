let s:static_dir = expand('<sfile>:p:h:h:h:h') . '/static/'
let s:css_files = ['github', 'highlight']
let s:js_files = ['highlight']
let s:stylesheet = ''
let s:javascript = ''

" {{{ https://github.com/mizyoukan/vim-quickrun-markdown-gfm/commit/0375e34d9fca3c3d74d5527023fcd66a48fb9dba
let s:base64table = [
\ "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
\ "Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f",
\ "g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v",
\ "w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/"]

function! s:base64encode(bytes)
    let l:b64 = []
    for i in range(0, len(a:bytes) - 1, 3)
        let l:n = a:bytes[i] * 0x10000
        \ + get(a:bytes, i + 1, 0) * 0x100
        \ + get(a:bytes, i + 2, 0)
        call add(l:b64, s:base64table[l:n / 0x40000])
        call add(l:b64, s:base64table[l:n / 0x1000 % 0x40])
        call add(l:b64, s:base64table[l:n / 0x40 % 0x40])
        call add(l:b64, s:base64table[l:n % 0x40])
    endfor
    if len(a:bytes) % 3 == 1
        let l:b64[-1] = '='
        let l:b64[-2] = '='
    elseif len(a:bytes) % 3 == 2
        let l:b64[-1] = '='
    endif
    return join(l:b64, '')
endfunction

function! s:readbytes(file)
    let l:bytes = []
    for line in readfile(a:file, 'b')
        if !empty(l:bytes)
            call add(l:bytes, 10)
        endif
        call extend(l:bytes
        \ , map(range(len(line))
        \   , 'char2nr(line[v:val]) == 10 ? 0 : char2nr(line[v:val])'))
    endfor
    return l:bytes
endfunction
" }}}

function! s:has_local_resource(html, attr_name)
    if a:html.name == 'img'
    \ && has_key(a:html, 'attr')
    \ && has_key(a:html.attr, a:attr_name)
    \ && match(get(a:html.attr, a:attr_name), '^\%(https?\|data\)?:') == -1
        return 1
    elseif
        return 0
    endif
endfunction

function! s:pack_local_resource(html)
    if a:html.name == 'img' && s:has_local_resource(a:html, 'src')
        let l:filename = expand('%:p:h') . '/' . a:html.attr.src
        if getftype(l:filename) == 'file'
            let a:html.attr.src = 'data:image/'
            \ . fnamemodify(l:filename, ':e')
            \ . ';base64,'
            \ . s:base64encode(s:readbytes(l:filename))
        endif
    elseif a:html.name == 'script' && s:has_local_resource(a:html, 'src')
        let l:filename = expand('%:p:h') . '/' . a:html.attr.src
        if getftype(l:filename) == 'file'
            unlet a:html.attr.src
            let a:html.child = [join(readfile(l:filename), "\n")]
        endif
    elseif a:html.name == 'link'
    \ && s:has_local_resource(a:html, 'href')
    \ && get(a:html.attr, 'rel', '') == 'stylesheet'
        let l:filename = expand('%:p:h') . '/' . a:html.attr.href
        if getftype(l:filename) == 'file'
            unlet a:html.attr.href
            return s:pack_resources({
            \   'name': 'style',
            \   'attr': a:html.attr,
            \   'child': [join(readfile(l:filename), "\n")]
            \ })
        endif
    endif
    return a:html
endfunction

function! s:pack_resources_recur(html)
    if type(a:html) == type('')
        return a:html
    endif
    let l:packed_html = s:pack_local_resource(a:html)
    if type(l:packed_html) == type('')
        return l:packed_html
    endif
    let l:attr_list = []
    for [attr_key, attr_val] in items(get(l:packed_html, 'attr', {}))
        call add(l:attr_list
        \ , attr_key . '=' . '"' . substitute(attr_val, '"', '&quot;', 'g') . '"')
    endfor
    let l:attr = join(l:attr_list, ' ')
    let l:child = ''
    for child_val in get(l:packed_html, 'child', [])
        let l:child .= s:pack_resources_recur(child_val)
        unlet child_val
    endfor
    return '<'
    \ . l:packed_html.name
    \ . (l:attr == '' ? '' : ' ' . l:attr)
    \ . (l:child == '' ? '/>' : '>' . l:child . '</' . l:packed_html.name . '>')
endfunction

function! s:pack_resources(data)
    return join(map(
    \   get(webapi#html#parse('<div>' . a:data . '</div>'), 'child', [])
    \   , 's:pack_resources_recur(v:val)')
    \ , '')
endfunction

let s:hook = {
\   'name': 'markdown_gfm'
\ , 'kind': 'hook'
\ , 'config': {'enable': 1}
\ }

function! s:hook.on_ready(session, context)
    let s:stylesheet = join(map(
    \   copy(s:css_files)
    \   , '"<style>" . join(readfile(s:static_dir . v:val . ".css"), "\n") . "</style>"')
    \ , "\n")
    let s:javascript = join(map(
    \   copy(s:js_files)
    \   , '"<script>" . join(readfile(s:static_dir . v:val . ".js"), "\n") . "</script>"')
    \ , "\n")
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

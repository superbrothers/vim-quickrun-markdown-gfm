if !exists('g:quickrun_markdown_gfm_github_api_url')
    let g:quickrun_markdown_gfm_github_api_url = 'https://api.github.com/markdown/raw'
endif

if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif

let s:curl_cmd = 'curl -X POST -H "Content-Type: text/plain" --data-binary \@%s -s ' . g:quickrun_markdown_gfm_github_api_url . '/markdown/raw '

" Use OAuth2 Token
if exists('g:quickrun_markdown_gfm_github_token')
    let s:curl_cmd .= '-H "Authorization: token ' . g:quickrun_markdown_gfm_github_token . '" '
endif

let g:quickrun_config['markdown/gfm'] = {
\   'exec': "call g:quickrun_markdown_gfm_render('" . expand('<sfile>:p:h') . "')",
\   'runner': 'vimscript'
\ }

function! g:quickrun_markdown_gfm_render(cwd)
    let l:param = join(getline(0, '$'), "\n")
    let l:header = {'Content-Type': 'text/plain'}
    let l:res = webapi#http#post(g:quickrun_markdown_gfm_github_api_url, l:param, l:header)
    let l:css1 = join(readfile(a:cwd . '/../static/github.css'))
    let l:css2 = join(readfile(a:cwd . '/../static/highlight.css'))
    let l:js1 = join(readfile(a:cwd . '/../static/highlight.js'))
    echo '<!doctype html><html lang="ja"><head><meta charset="UTF-8"><style>' . l:css1 . '</style><style>' . l:css2 . '</style><script>' . l:js1 . '</script></head><body>' . l:res.content . '</body></html>'
endfunction

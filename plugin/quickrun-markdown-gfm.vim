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
\   'exec': "call g:quickrun_markdown_gfm_render()",
\   'runner': 'vimscript'
\ }

function! g:quickrun_markdown_gfm_render()
    let l:param = join(getline(0, '$'), "\n")
    let l:header = {'Content-Type': 'text/plain'}
    let l:res = webapi#http#post(g:quickrun_markdown_gfm_github_api_url, l:param, l:header)
    echo l:res.content
endfunction

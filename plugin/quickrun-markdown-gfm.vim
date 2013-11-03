
if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif

if exists('g:quickrun_markdown_gfm_github_api_url')
    " use OAuth2 Token(sent in a header)
    let g:quickrun_config['markdown/gfm'] = {
    \   'exec': 'curl -X POST -H "Content-Type: text/plain" -H "Authorization: token '.g:quickrun_markdown_gfm_github_token.'" --data-binary \@%s -s '. g:quickrun_markdown_gfm_github_api_url . '/markdown/raw | ' . expand('<sfile>:p:h') . '/../image2base64.sh | ' . expand('<sfile>:p:h') . '/../render.sh'
    \ }
elseif
    let g:quickrun_config['markdown/gfm'] = {
    \   'exec': 'curl -X POST -H "Content-Type: text/plain" --data-binary \@%s -s https://api.github.com/markdown/raw | ' . expand('<sfile>:p:h') . '/../image2base64.sh | ' . expand('<sfile>:p:h') . '/../render.sh'
    \ }
endif


if !exists('g:quickrun_markdown_gfm_github_api_url')
    let g:quickrun_markdown_gfm_github_api_url = 'https://api.github.com'
endif

if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif

let g:quickrun_config['markdown/gfm'] = {
\   'exec': 'curl -X POST -H "Content-Type: text/plain" --data-binary \@%s -s '. g:quickrun_markdown_gfm_github_api_url . '/markdown/raw | ' . expand('<sfile>:p:h') . '/../render.sh'
\ }

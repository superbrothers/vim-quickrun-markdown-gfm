let s:cpo_save = &cpo
set cpo&vim

if !exists('g:quickrun_markdown_gfm_github_api_url')
    let g:quickrun_markdown_gfm_github_api_url = 'https://api.github.com'
endif

if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif

let g:quickrun_config['markdown/gfm'] = {
\   'exec': 'call quickrun_markdown_gfm#render()'
\ , 'runner': 'vimscript'
\ , 'hook/markdown_gfm/enable': 1
\ }

let &cpo = s:cpo_save
unlet s:cpo_save

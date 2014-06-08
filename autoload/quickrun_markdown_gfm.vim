let s:cpo_save = &cpo
set cpo&vim

function! quickrun_markdown_gfm#render()
    let header = {'Content-Type': 'text/plain'}
    if exists('g:quickrun_markdown_gfm_github_token')
        let header['Authorization'] = 'token ' . g:quickrun_markdown_gfm_github_token
    endif
    let res = webapi#http#post(
    \ g:quickrun_markdown_gfm_github_api_url . '/markdown/raw'
    \ , join(getline(0, '$'), "\n")
    \ , header)
    if res.status =~ '^2'
        echo res.content
    else
        echo '<p style="color:red;">[' . res.status . '] Post failed: ' . res.message . '<p>'
    endif
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

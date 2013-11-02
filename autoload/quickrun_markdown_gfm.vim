function! quickrun_markdown_gfm#render()
    let l:param = join(getline(0, '$'), "\n")
    let l:header = {'Content-Type': 'text/plain'}
    let l:res = webapi#http#post(g:quickrun_markdown_gfm_github_api_url, l:param, l:header)
    echo l:res.content
endfunction

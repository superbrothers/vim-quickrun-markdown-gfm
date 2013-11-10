function! quickrun_markdown_gfm#render()
    echo webapi#http#post(
    \ g:quickrun_markdown_gfm_github_api_url
    \ , join(getline(0, '$'), "\n")
    \ , {'Content-Type': 'text/plain'}).content
endfunction

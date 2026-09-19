let s:profiles = {}

function! s:profile_path(file) abort
    if empty(a:file)
        return ''
    endif
    return findfile('.vim-project.json', fnamemodify(a:file, ':p:h') . ';')
endfunction

function! s:profile(file) abort
    let l:path = s:profile_path(a:file)
    if empty(l:path)
        return [{}, '']
    endif
    let l:path = fnamemodify(l:path, ':p')
    if !has_key(s:profiles, l:path)
        try
            let s:profiles[l:path] = json_decode(join(readfile(l:path), "\n"))
        catch
            echohl ErrorMsg
            echom 'Invalid Vim project profile: ' . l:path
            echohl None
            let s:profiles[l:path] = {}
        endtry
    endif
    return [s:profiles[l:path], fnamemodify(l:path, ':h')]
endfunction

function! s:absolute(root, path) abort
    return fnamemodify(a:root . '/' . a:path, ':p')
endfunction

function! s:inside(file, directory) abort
    let l:file = resolve(fnamemodify(a:file, ':p'))
    let l:directory = resolve(fnamemodify(a:directory, ':p'))
    return l:file ==# l:directory || stridx(l:file, l:directory . '/') == 0
endfunction

function! s:matches_paths(file, root, include, exclude) abort
    for l:path in a:exclude
        if s:inside(a:file, s:absolute(a:root, l:path))
            return v:false
        endif
    endfor
    for l:path in a:include
        if s:inside(a:file, s:absolute(a:root, l:path))
            return v:true
        endif
    endfor
    return empty(a:include)
endfunction

function! configs_project#tags_enabled(file) abort
    let [l:profile, l:root] = s:profile(a:file)
    return get(get(l:profile, 'tags', {}), 'enabled', v:false)
endfunction

function! configs_project#apply() abort
    let [l:profile, l:root] = s:profile(expand('%:p'))
    let b:configs_project_profile = l:profile
    let b:configs_project_root = l:root
    let b:configs_completion_enabled = index(['json', 'jsonc'], &filetype) >= 0
                \ ? v:true
                \ : get(get(l:profile, 'completion', {}), 'enabled', v:false)

    if index(['json', 'jsonc'], &filetype) >= 0
        let b:ale_enabled = 0
        setlocal omnifunc=lsp#complete
    endif

    if empty(l:profile)
        return
    endif

    if index(['json', 'jsonc'], &filetype) < 0
        let b:ale_enabled = get(l:profile, 'ale', v:true)
    endif
    let b:ale_completion_enabled = 0
    if &filetype ==# 'python'
        let l:python = get(l:profile, 'python', {})
        if get(l:python, 'enabled', v:false)
                    \ && s:matches_paths(expand('%:p'), l:root,
                    \     get(l:python, 'roots', []), get(l:python, 'exclude', []))
            let b:ale_enabled = 0
            if b:configs_completion_enabled
                setlocal omnifunc=lsp#complete
            endif
        endif
    elseif index(['c', 'cpp', 'cuda', 'objc', 'objcpp'], &filetype) >= 0
        for l:project in get(get(l:profile, 'clangd', {}), 'projects', [])
            let l:source = s:absolute(l:root, get(l:project, 'source', '.'))
            if s:inside(expand('%:p'), l:source)
                let l:database = s:absolute(l:root, l:project.compilation_database)
                let b:ale_root = l:source
                let b:ale_linters = ['clangd']
                let b:ale_c_build_dir = l:database
                if b:configs_completion_enabled
                    setlocal omnifunc=ale#completion#OmniFunc
                endif
                break
            endif
        endfor
    endif
endfunction

function! configs_project#zuban_cmd() abort
    let [l:profile, l:root] = s:profile(expand('%:p'))
    let l:python = get(l:profile, 'python', {})
    if !get(l:python, 'enabled', v:false)
                \ || !s:matches_paths(expand('%:p'), l:root,
                \     get(l:python, 'roots', []), get(l:python, 'exclude', []))
        return []
    endif
    return [get(l:python, 'executable', 'zuban'), 'server']
endfunction

function! configs_project#zuban_root_uri() abort
    let [l:profile, l:root] = s:profile(expand('%:p'))
    return empty(l:profile) ? '' : lsp#utils#path_to_uri(l:root)
endfunction

function! configs_project#json_root_uri() abort
    let l:start = fnamemodify(expand('%:p'), ':h')
    let l:git = finddir('.git', l:start . ';')
    let l:root = empty(l:git) ? l:start : fnamemodify(l:git, ':h')
    return lsp#utils#path_to_uri(l:root)
endfunction

function! configs_project#register_lsp() abort
    call lsp#register_server({
                \ 'name': 'zuban',
                \ 'cmd': {server_info -> configs_project#zuban_cmd()},
                \ 'root_uri': {server_info -> configs_project#zuban_root_uri()},
                \ 'allowlist': ['python'],
                \ })
    if executable('vscode-json-language-server')
        call lsp#register_server({
                    \ 'name': 'vscode-json-language-server',
                    \ 'cmd': {server_info -> ['vscode-json-language-server', '--stdio']},
                    \ 'root_uri': {server_info -> configs_project#json_root_uri()},
                    \ 'allowlist': ['json', 'jsonc'],
                    \ })
    endif
endfunction

function! configs_project#lsp_buffer() abort
    if index(['json', 'jsonc'], &filetype) >= 0
                \ || (!empty(get(b:, 'configs_project_profile', {}))
                \     && &filetype ==# 'python'
                \     && get(b:, 'configs_completion_enabled', 0))
        setlocal omnifunc=lsp#complete
        nmap <buffer> K <plug>(lsp-hover)
        nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> gr <plug>(lsp-references)
    endif
endfunction

function! configs_project#tab() abort
    let l:column = col('.') - 1
    if !get(b:, 'configs_completion_enabled', 0)
                \ || l:column == 0
                \ || getline('.')[l:column - 1] =~# '\s'
        return "\<Tab>"
    endif
    return "\<Plug>(MUcompleteFwd)"
endfunction

function! configs_project#shift_tab() abort
    return get(b:, 'configs_completion_enabled', 0)
                \ ? "\<Plug>(MUcompleteBwd)"
                \ : "\<C-D>"
endfunction

function! configs_project#enter() abort
    if pumvisible()
        return complete_info(['selected']).selected < 0
                    \ ? "\<C-N>\<C-Y>"
                    \ : "\<C-Y>"
    endif
    if &filetype ==# 'python'
                \ && strpart(getline('.'), 0, col('.') - 1) =~# '"""$'
                \ && strpart(getline('.'), col('.') - 1) =~# '^"""'
        return "\<CR>\<CR>\<Up>" . repeat(' ', indent('.'))
    endif
    return "\<CR>"
endfunction

function! configs_project#python_quote() abort
    if strpart(getline('.'), 0, col('.') - 1) =~# '""$'
        return '""""' . "\<Left>\<Left>\<Left>"
    endif
    return '"'
endfunction

function! configs_project#python_mappings() abort
    inoremap <buffer> <silent> <expr> <Char-34> configs_project#python_quote()
endfunction

function! configs_project#toggle_completion() abort
    let b:configs_completion_enabled = !get(b:, 'configs_completion_enabled', 0)
    if b:configs_completion_enabled
        if &filetype ==# 'python'
            setlocal omnifunc=lsp#complete
        elseif index(['c', 'cpp', 'cuda', 'objc', 'objcpp'], &filetype) >= 0
            setlocal omnifunc=ale#completion#OmniFunc
        endif
    else
        setlocal omnifunc=
    endif
    echo 'Project completion ' . (b:configs_completion_enabled ? 'enabled' : 'disabled')
endfunction

function! configs_project#info() abort
    if empty(get(b:, 'configs_project_profile', {}))
        echo 'No .vim-project.json found'
        return
    endif
    let l:backend = &filetype ==# 'python' ? 'vim-lsp' : 'ALE'
    echo printf('%s | completion: %s | language: %s | tags: %s',
                \ get(b:configs_project_profile, 'name', fnamemodify(b:configs_project_root, ':t')),
                \ get(b:, 'configs_completion_enabled', 0) ? 'on' : 'off',
                \ l:backend,
                \ configs_project#tags_enabled(expand('%:p')) ? 'on' : 'off')
endfunction

function! configs_project#setup() abort
    call mkdir(g:gutentags_cache_dir, 'p')

    imap <expr> <silent> <Tab> configs_project#tab()
    imap <expr> <silent> <S-Tab> configs_project#shift_tab()
    imap <expr> <silent> <CR> configs_project#enter()

    command! ProjectCompletionToggle call configs_project#toggle_completion()
    command! ProjectInfo call configs_project#info()

    augroup configs_project
        autocmd!
        autocmd BufReadPost,BufNewFile,FileType * call configs_project#apply()
        autocmd FileType python call configs_project#python_mappings()
        autocmd User lsp_setup call configs_project#register_lsp()
        autocmd User lsp_buffer_enabled call configs_project#lsp_buffer()
    augroup END

    if &filetype ==# 'python'
        call configs_project#python_mappings()
    endif
endfunction

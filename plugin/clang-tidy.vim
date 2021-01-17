augroup clang-tidy
    au!
    au BufWritePre *.cpp lua require'clang_tidy'.delete_old_diags()
    au BufWritePost *.cpp lua require'clang_tidy'.clang_tidy:start()
augroup END

augroup clang-tidy
    au!
    au BufWritePre,BufEnter *.cpp lua require('clang_tidy').clang_tidy:start()
augroup END

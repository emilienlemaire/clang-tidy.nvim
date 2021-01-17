augroup clang-tidy
    au!
    au BufWritePost *.cpp lua require('clang_tidy').clang_tidy:start()
augroup END

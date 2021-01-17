augroup clang-tidy
    au!
    au BufWritePre *.cpp :lua require('clang_tidy').clang-tidy:start()<cr>
augroup END

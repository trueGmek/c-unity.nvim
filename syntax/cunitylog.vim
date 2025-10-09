" syntax/cunitylog.vim

if exists("b:current_syntax")
  finish
endif

syn case match

syn match cunityTimestamp  "\v\[\d{2}:\d{2}:\d{2}(:\d*)?\]"
syn match cunityError      "\v\[Error\]"
syn match cunityWarn       "\v\[Warning\]"
syn match cunityInfo       "\v\[Log\]"
syn match cunityNvim       "\v\[Nvim\]"
syn match cunityUnity      "\v\[Unity\]"
syn match cunityDebug      "\v\[Debug\]"
syn match cunityException  "\v\[Exception\]"
syn match cunityStacktrace "\v\(at .{-}:\d+\)"

" --- Highlighting ---
hi def link cunityDebug      Comment
hi def link cunityStacktrace Directory

hi cunityInfo       guifg=Green  guibg=NONE gui=bold
hi cunityNvim       guifg=Pink   guibg=NONE gui=bold
hi cunityUnity      guifg=White  guibg=NONE gui=bold
hi cunityError      guifg=Red    guibg=NONE gui=bold
hi cunityException  guifg=Red    guibg=NONE gui=bold
hi cunityWarn       guifg=Yellow guibg=NONE gui=bold
hi cunityTimestamp  guifg=Orange guibg=NONE gui=bold

let b:current_syntax = "cunitylog"

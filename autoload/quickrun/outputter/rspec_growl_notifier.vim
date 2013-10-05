" Author : joker1007 <kakyoin.hierophant@gmail.com>
" License: MIT License http://www.opensource.org/licenses/mit-license.php

" loading guard {{{
if exists('g:quickrun_rspec_growl_notifier_outputter_loaded') && g:quickrun_rspec_growl_notifier_outputter_loaded
    finish
endif
let g:quickrun_rspec_growl_notifier_outputter_loaded = 1
"}}}

" check if executable {{{
if !executable('growlnotify')
    echoerr "this outputter needs growlnotify!\nsee below URL\nhttp://growl.info/downloads#generaldownloads"
    finish
endif
"}}}

let s:save_cpo = &cpo
set cpo&vim

" variables {{{
" notification title
if !has('g:outputter_rspec_growl_notifier_title')
    let g:outputter_rspec_growl_notifier_title = 'vim-quickrun'
endif

" notification icon
if !has('g:outputter_rspec_growl_notifier_icon')
    let g:outputter_rspec_growl_notifier_icon = '/Applications/MacVim.app'
endif

let s:has_vimproc = globpath(&rtp, 'autoload/vimproc.vim') != ''
"}}}

" outputter {{{
let s:outputter = quickrun#outputter#buffered#new()

function! s:outputter.finish(session)
    let result = escape(self._result, '"')

    let re = '\(\d\+\) examples\?, \(\d\+\) failures\?'
    let matched = matchstr(self._result, re)
    let examples = substitute(matched, re, '\1', '')
    let failed = substitute(matched, re, '\2', '')

    if (failed == '0')
      let message = 'Success: ' . examples . ' examples'
    else
      let message = 'Failed: ' . examples . ' examples, ' . failed . ' failures'
    endif

    echom message

    let cmd = 'growlnotify -m "'. message .
                    \'" --name "' . 'vim-quickrun' .
                    \'" --appIcon "' . g:outputter_rspec_growl_notifier_icon . '"'
    if s:has_vimproc
      call vimproc#system(cmd .
                    \' "' . g:outputter_rspec_growl_notifier_title . '"')
    else
      call system(cmd .
                    \' "' . g:outputter_rspec_growl_notifier_title . '"')
    endif
endfunction

function! quickrun#outputter#rspec_growl_notifier#new()
    return deepcopy(s:outputter)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

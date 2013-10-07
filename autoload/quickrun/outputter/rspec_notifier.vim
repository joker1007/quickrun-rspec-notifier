" Author : joker1007 <kakyoin.hierophant@gmail.com>
" License: MIT License http://www.opensource.org/licenses/mit-license.php

" loading guard {{{
if exists('g:quickrun_rspec_notifier_outputter_loaded') && g:quickrun_rspec_notifier_outputter_loaded
    finish
endif
let g:quickrun_rspec_notifier_outputter_loaded = 1
"}}}

" check if executable {{{
if executable('growlnotify')
    let g:has_growlnotify = 1
else
    let g:has_growlnotify = 0
endif

if executable('notify-send')
    let g:has_notifysend = 1
else
    let g:has_notifysend = 0
endif
"}}}

let s:save_cpo = &cpo
set cpo&vim

" variables {{{
" notification title
if !has('g:outputter_rspec_notifier_title')
    let g:outputter_rspec_notifier_title = 'vim-quickrun'
endif

" notification icon
if !has('g:outputter_rspec_notifier_icon')
    let g:outputter_rspec_notifier_icon = {
          \ 'success': expand('<sfile>:p:h') . '/../../../images/success.png',
          \ 'failure': expand('<sfile>:p:h') . '/../../../images/failure.png',
          \}
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
      let icon  = g:outputter_rspec_notifier_icon.success
    else
      let message = 'Failed: ' . examples . ' examples, ' . failed . ' failures'
      let icon  = g:outputter_rspec_notifier_icon.failure
    endif

    echom message

    if g:has_growlnotify
      let cmd = 'growlnotify -m "'. message .
                      \'" --name "' . 'vim-quickrun' .
                      \'" --image "' . icon . '"'
      if s:has_vimproc
        call vimproc#system(cmd .
                      \' "' . g:outputter_rspec_notifier_title . '"')
      else
        call system(cmd .
                      \' "' . g:outputter_rspec_notifier_title . '"')
      endif
    endif

    if g:has_notifysend && !g:has_growlnotify
      let cmd = 'notify-send -u "'. normal .
                      \'" -i "' . icon .
                      \'" "' . message . '"'
      if s:has_vimproc
        call vimproc#system(cmd)
      else
        call system(cmd)
      endif
    endif
endfunction

function! quickrun#outputter#rspec_notifier#new()
    return deepcopy(s:outputter)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

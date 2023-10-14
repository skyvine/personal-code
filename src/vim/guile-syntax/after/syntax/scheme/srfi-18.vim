" Threads {{{
syntax keyword guileFunction current-thread thread? make-thread thread-name
syntax keyword guileFunction thread-specific thread-specific-set! thread-start!
syntax keyword guileFunction thread-join! thread-yield! thread-sleep! thread-terminate!
" }}}

" Mutexes {{{
syntax keyword guileFunction make-mutex mutex-name mutex-specific mutex-specific-set!
syntax keyword guileFunction mutex-state mutex-lock! mutex-unlock!
" }}}

" Condition Variables {{{
syntax keyword guileFunction condition-variable? make-condition-variable
syntax keyword guileFunction condition-variable-name condition-variable-specific
syntax keyword guileFunction condition-variable-specific-set!
syntax keyword guileFunction condition-variable-signal! condition-variable-broadcast!
" }}}

" Time {{{
syntax keyword guileFunction current-time time? time->seconds seconds->time
" }}}

" Exceptions {{{
syntax keyword guileSyntax with-exception-handler
syntax keyword guileFunction current-exception-handler raise
syntax keyword guileFunction join-timeout-exception? abandoned-mutex-exception?
syntax keyword guileFunction terminated-thread-exception?
syntax keyword guileFunction uncaught-exception? uncaught-exception-reason
" }}}

" Time {{{
syntax keyword guileConstant time-utc time-tai time-monotonic time-duration time-process
syntax keyword guileConstant time-thread

syntax keyword guileFunction time? make-time time-type time-nanosecond time-second
syntax keyword guileFunction set-time-type! set-time-nanosecond! set-time-second!
syntax keyword guileFunction copy-time current-time time-resolution
syntax keyword guileFunction time<=? time<? time=? time>=? time>?
syntax keyword guileFunction time-difference time-difference!
syntax keyword guileFunction add-duration add-duration!
syntax keyword guileFunction subtract-duration subtract-duration!
" }}}

" Date {{{
syntax keyword guileFunction date? make-date date-second date-nanosecond date-minute
syntax keyword guileFunction date-hour date-day date-month date-year date-zone-offset
syntax keyword guileFunction date-year-day date-week-day date-week-number current-date
syntax keyword guileFunction current-julian-day current-modified-julian-day
" }}}

" Conversion {{{
syntax keyword guileFunction date->julian-day date->modified-julian-day
syntax keyword guileFunction date->time-monotonic date->time-tai date->time-utc

syntax keyword guileFunction julian-day->date julian-day->modified-julian-day
syntax keyword guileFunction julian-day->time-monotonic julian-day->time-tai
syntax keyword guileFunction julian-day->time-utc

syntax keyword guileFunction modified-julian-day->date modified-julian-day->julian-day
syntax keyword guileFunction modified-julian-day->time-monotonic
syntax keyword guileFunction modified-julian-day->time-tai modified-julian-day->time-utc

syntax keyword guileFunction time-monotonic->julian-day
syntax keyword guileFunction time-monotonic->modified-julian-day
syntax keyword guileFunction time-monotonic->date time-monotonic->time-tai
syntax keyword guileFunction time-monotonic->time-utc
syntax keyword guileFunction time-monotonic->time-tai! time-monotonic-time-utc!

syntax keyword guileFunction time-tai->julian-day time-tai->modified-julian-day
syntax keyword guileFunction time-tai->time-monotonic time-tai->date time-tai->time-utc
syntax keyword guileFunction time-tai->time-monotonic! time-tai->time-utc!

syntax keyword guileFunction time-utc->julian-day time-utc->modified-julian-day
syntax keyword guileFunction time-utc->time-monotonic time-utc->date time-utc->time-tai
syntax keyword guileFunction time-utc->time-monotonic! time-utc->time-tai!
" }}}

" Formatting {{{
syntax keyword guileFunction date->string string->date
" }}}

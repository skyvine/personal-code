" Highlight Definitions {{{
highlight link guileComment schemeMultilineComment
highlight link guileFunction schemeFunction
highlight link guileParameter schemeFunction
highlight link guileLibrarySyntax schemeLibrarySyntax
highlight link guileSyntax schemeSyntax
highlight link guileType schemeTypeSyntax

highlight guileKeyword cterm=italic gui=italic
" }}}

" Association Lists {{{
syntax keyword guileFunction acons assq-set! assv-set! assoc-set!
syntax keyword guileFunction assq-ref assv-ref assoc-ref
syntax keyword guileFunction assq-remove! assv-remove! assoc-remove!
syntax keyword guileFunction sloppy-assq sloppy-assv sloppy-assoc
" }}}

" Arrays {{{
syntax keyword guileFunction array? make-array typed-array? make-typed-array
syntax keyword guileFunction list->array list->typed-array array-type array-ref
syntax keyword guileFunction array-in-bounds? array-set!
syntax keyword guileFunction array-shape array-dimensions array-length array-rank
syntax keyword guileFunction array->list array-copy! array-fill!
syntax keyword guileFunction array-equal? array-map! array-map-in-order!
syntax keyword guileFunction array-for-each array-index-map! array-copy
syntax keyword guileFunction make-shared-array shared-array-increments
syntax keyword guileFunction shared-array-offset shared-array-root
syntax keyword guileFunction array-contents transpose-array
syntax keyword guileFunction array-cell-ref array-slice array-cell-set!
syntax keyword guileFunction array-slice-for-each array-slice-for-each-in-order
" }}}

" Bitvectors {{{
syntax keyword guileFunction bitvector? make-bitvector bitvector bitvector-length
syntax keyword guileFunction bitvector-bit-set? bitvector-bit-clear?
syntax keyword guileFunction bitvector-bit-set! bitvector-bit-clear!
syntax keyword guileFunction bitvector-set-all-bits! bitvector-clear-all-bits!
syntax keyword guileFunction bitvector-set-flip-all-bits!
syntax keyword guileFunction list->bitvector bitvector->list
syntax keyword guileFunction bitvector-copy bitvector-count bitvector-count-bits
syntax keyword guileFunction bitvector-position bitvector-set-bits! bitvector-clear-bits!
" }}}

" Bytevectors {{{
syntax keyword guileFunction native-endianness endianness
syntax keyword guileFunction bytevector=? bytevector-fill!

syntax keyword guileFunction bytevector-uint-ref  bytevector-sint-ref
syntax keyword guileFunction bytevector-uint-set! bytevector-sint-ref!

syntax keyword guileFunction bytevector-u16-ref bytevector-u16-set!
syntax keyword guileFunction bytevector-u32-ref bytevector-u32-set!
syntax keyword guileFunction bytevector-u64-ref bytevector-u64-set!
syntax keyword guileFunction bytevector-s8-ref bytevector-s8-set!
syntax keyword guileFunction bytevector-s16-ref bytevector-s16-set!
syntax keyword guileFunction bytevector-s32-ref bytevector-s32-set!
syntax keyword guileFunction bytevector-s64-ref bytevector-s64-set!

syntax keyword guileFunction bytevector-u8-native-ref bytevector-u8-native-set!
syntax keyword guileFunction bytevector-u16-native-ref bytevector-u16-native-set!
syntax keyword guileFunction bytevector-u32-native-ref bytevector-u32-native-set!
syntax keyword guileFunction bytevector-u64-native-ref bytevector-u64-native-set!
syntax keyword guileFunction bytevector-s8-native-ref bytevector-s8-native-set!
syntax keyword guileFunction bytevector-s16-native-ref bytevector-s16-native-set!
syntax keyword guileFunction bytevector-s32-native-ref bytevector-s32-native-set!
syntax keyword guileFunction bytevector-s64-native-ref bytevector-s64-native-set!

syntax keyword guileFunction bytevector->u8-list u8-list->bytevector
syntax keyword guileFunction bytevector->uint-list uint-list->bytevector
syntax keyword guileFunction bytevector->sint-list sint-list->bytevector

syntax keyword guileFunction bytevector-ieee-single-ref bytevector-ieee-double-ref
syntax keyword guileFunction bytevector-ieee-single-native-ref bytevector-ieee-double-native-ref
syntax keyword guileFunction bytevector-ieee-single-set! bytevector-ieee-double-set!
syntax keyword guileFunction bytevector-ieee-single-native-set! bytevector-ieee-double-native-set!

syntax keyword guileFunction string-utf8-length
syntax keyword guileFunction string->utf16 utf16->string
syntax keyword guileFunction string->utf32 utf32->string

syntax keyword guileFunction get-u8 lookahead-u8 get-bytevector-n get-bytevector-n!
syntax keyword guileFunction get-bytevector-some get-bytevector-some! get-bytevector-all
syntax keyword guileFunction unget-bytevector put-u8 put-bytevector

syntax keyword guileFunction call-with-output-bytevector call-with-input-bytevector
syntax keyword guileFunction open-bytevector-input-port open-bytevector-output-port

syntax keyword guileFunction pointer->bytevector bytevector->pointer dereference-pointer
" }}}

" Characters {{{
syntax keyword guileFunction char-is-both? char-general-category char-titlecase
syntax keyword guileFunction char->formal-name formal-name->char
syntax keyword guileFunction get-char lookahead-char unget-char put-char
" }}}

" Character Sets {{{
syntax keyword guileFunction char-set? char-set= char-set<= char-set-hash
syntax keyword guileFunction char-set-cursor char-set-ref char-set-cursor-next
syntax keyword guileFunction end-of-char-set? char-set-fold char-set-unfold
syntax keyword guileFunction char-set-unfold! char-set-for-each char-set-map
syntax keyword guileFunction char-set-copy char-set list->char-set list->char-set]
syntax keyword guileFunction string->char-set string->char-set!
syntax keyword guileFunction char-set-filter char-set-filter!
syntax keyword guileFunction ucs-range->char-set ucs-range->char-set! ->char-set
syntax keyword guileFunction %char-set-dump char-set-size char-set-count
syntax keyword guileFunction char-set->list char-set->string
syntax keyword guileFunction char-set-contains? char-set-every char-set-any
syntax keyword guileFunction char-set-adjoin char-set-delete
syntax keyword guileFunction char-set-adjoin! char-set-delete!
syntax keyword guileFunction char-set-complement char-set-union
syntax keyword guileFunction char-set-union char-set-intersection char-set-difference
syntax keyword guileFunction char-set-xor char-set-diff+intersection
syntax keyword guileFunction char-set-complement! char-set-union!
syntax keyword guileFunction char-set-union! char-set-intersection! char-set-difference!
syntax keyword guileFunction char-set-xor! char-set-diff+intersection!
" }}}

" Comments {{{
syntax region guileComment  start='#!' end='!#'
" }}}

" Debugging {{{
syntax keyword guileFunction make-stack stack? stack-id stack-length stack-ref
syntax keyword guileFunction display-stacktrace frame? frame-previous frame-procedure-name
syntax keyword guileFunction frame-address frame-arguments frame-instruction-pointer
syntax keyword guileFunction frame-stack-pointer frame-dynamic-link frame-return-address
syntax keyword guileFunction frame-mv-return-address frame-bindings frame-lookup-binding

syntax keyword guileFunction binding-index binding-name binding-slot
syntax keyword guileFunction binding-representation binding-ref binding-set!

syntax keyword guileFunction display-application

syntax keyword guileFunction supports-source-properties? set-source-properties!
syntax keyword guileFunction set-source-property! set-source-properties!
syntax keyword guileFunction source-property source-properties
syntax keyword guileFunction current-source-location current-filename cons-source

syntax keyword guileFunction backtrace
syntax keyword guileFunction call-with-error-handling call-with-stack-overflow-handler

syntax keyword guileFunction debug-options debug-enable debug-disable debug-set!

syntax keyword guileFunction statprof statprof-active? statprof-start statprof-stop
syntax keyword guileFunction statprof-reset statprof-accumulated-time
syntax keyword guileFunction statprof-sample-count statprof-fold-call-data
syntax keyword guileFunction statprof-proc-call-data statprof-call-data-name
syntax keyword guileFunction statprof-call-data-calls statprof-call-data-cum-samples
syntax keyword guileFunction statprof-call-data-self-samples statprof-call-data->stats
syntax keyword guileFunction statprof-stats-proc-name statprof-stats-%-time-in-proc
syntax keyword guileFunction statprof-stats-cum-secs-in-proc
syntax keyword guileFunction statprof-stats-self-secs-in-proc
syntax keyword guileFunction statprof-stats-cum-secs-per-call
syntax keyword guileFunction statprof-display statprof-fetch-stacks
syntax keyword guileFunction statprof-fetch-call-tree gcprof
" }}}

" Definitions, Destructuring, & Callables {{{
syntax keyword guileSyntax lambda* case-lambda*

syntax keyword guileSyntax define* define*-public
syntax keyword guileSyntax define-public define-once define-values
syntax keyword guileFunction defined?

syntax keyword guileSyntax defmacro* defmacro*-public

syntax keyword guileSyntax let-optional let-optional* let-keywords let-keywords*

syntax keyword guileSyntax receive match
syntax keyword guileSyntax match-lambda match-lambda*
syntax keyword guileSyntax match-let match-let* match-letrec
" }}}

" Evaluation, Compilation, & Environments {{{
syntax keyword guileFunction eval-string primitive-eval compile compile-file
syntax keyword guileFunction compiled-file-name load-compiled primitive-load
syntax keyword guileParameter default-optimization-level default-warning-level
syntax keyword guileFunction local-eval local-compile
syntax keyword guileSyntax the-environment scheme-report-environment null-environment

syntax keyword guileFunction load-from-path current-load-por
syntax keyword guileSyntax add-to-load-path primitive-load-path %search-load-path
syntax keyword guileFunction parse-path parse-path-with-ellipsis search-path

syntax keyword guileSyntax delay 
syntax keyword guileFunction promise force

syntax keyword guileSyntax include include-from-path

syntax keyword guileSyntax call-with-time-limit call-with-allocation-limit
syntax keyword guileSyntax call-with-time-and-allocation-limits
syntax keyword guileSyntax eval-in-sandbox
syntax keyword guileFunction make-sandbox-module

syntax keyword guileFunction load-foreign-library foreign-library? load-extension
syntax keyword guileFunction foreign-library-pointer pointer-address make-pointer
syntax keyword guileFunction pointer? null-pointer? scm->pointer pointer->scm
syntax keyword guileParameter guile-extensions-path ltdl-library-path
syntax keyword guileParameter guile-system-extensions-path
" }}}

" Exceptions {{{
syntax keyword guileSyntax error false-if-exception
syntax keyword guileFunction strerror display-error
syntax keyword guileSyntax raise-exception with-exception-handler
syntax keyword guileSyntax throw catch with-throw-handler
syntax keyword guileFunction make-exception-from-throw exception-kind exception-args

syntax keyword guileType &exception
syntax keyword guileSyntax define-exception-type
syntax keyword guileFunction exception-type? make-exception-type make-exception exception?
syntax keyword guileFunction exception-predicate exception-accessor 

syntax keyword guileType &warning
syntax keyword guileFunction make-warning warning?

syntax keyword guileType &error
syntax keyword guileFunction make-error error?

syntax keyword guileType &external-error
syntax keyword guileFunction make-external-error external-error?

syntax keyword guileType &programming-error
syntax keyword guileFunction make-programming-error programming-error?

syntax keyword guileType &non-continuable-error
syntax keyword guileFunction make-non-continuable-error non-continuable-error?

syntax keyword guileType &lexical-error
syntax keyword guileFunction make-lexical-error lexical-error?

syntax keyword guileType &syntax-error
syntax keyword guileFunction make-syntax-error syntax-error?
syntax keyword guileFunction syntax-error-form syntax-error-subform

syntax keyword guileType &undefined-variable-error
syntax keyword guileFunction make-undefined-variable-error undefined-variable-error?

syntax keyword guileType &message
syntax keyword guileFunction exception-message
syntax keyword guileFunction make-exception-with-message exception-with-message?

syntax keyword guileType &irritants
syntax keyword guileFunction exception-irritants
syntax keyword guileFunction make-exception-with-irritants exception-with-irritants?

syntax keyword guileType &origin
syntax keyword guileFunction exception-origin
syntax keyword guileFunction make-exception-with-origin exception-with-origin?
" }}}

" File Tree Walk {{{
syntax keyword guileFunction file-system-tree file-system-fold scandir ftw nftw
" }}}

" Formatting {{{
syntax keyword guileFunction simple-format print-options print-set! format pretty-print
syntax keyword guileFunction truncated-print
" }}}

" Flow Control {{{
syntax keyword guileSyntax while break continue
syntax keyword guileSyntax dynamic-wind

syntax keyword guileSyntax with-continuation-barrier
syntax keyword guileSyntax call-with-escape-continuation call/ec
syntax keyword guileSyntax let-escape-continuation let/ec
syntax keyword guileSyntax call-with-current-continuation call/cc
syntax keyword guileFunction suspendable-continuation?

syntax keyword guileSyntax % abort reset shift

syntax keyword guileSyntax call-with-prompt abort-to-prompt
syntax keyword guileFunction make-prompt-tag default-prompt-tag
" }}}

" Fluids {{{
syntax keyword guileFunction make-fluid make-unbound-fluid fluid? fluid-ref fluid-set!
syntax keyword guileFunction fluid-ref* fluid-unset! fluid-bound?
syntax keyword guileSyntax with-fluids with-fluids* with-fluid*

syntax keyword guileSyntax with-dynamic-state
syntax keyword guileFunction dynamic-state? current-dynamic-state
syntax keyword guileFunction set-current-dynamic-state

syntax keyword guileFunction fluid->parameter
" }}}

" Garbage Collector & Memory Management {{{
syntax keyword guileFunction gc gc-stats gc-live-object-stats make-guardian malloc-states
syntax keyword guileFunction make-weak-key-hash-table make-weak-value-hash-table
syntax keyword guileFunction make-doubly-weak-hash-table
syntax keyword guileFunction weak-key-hash-table? weak-value-hash-table?
syntax keyword guileFunction doubly-weak-hash-table?
syntax keyword guileFunction make-weak-vector weak-vector weak-vector?
syntax keyword guileFunction weak-vector-ref weak-vector-set!
" }}}

" GOOPS {{{
syntax keyword guileFunction goops-error

" Classes
syntax keyword guileSyntax define-class
syntax keyword guileFunction class-name class-direct-supers class-direct-slots
syntax keyword guileFunction class-direct-subclasses class-direct-methods
syntax keyword guileFunction class-precedence-list class-slots class-subclasses
syntax keyword guileFunction class-methods

" Generics/Methods
syntax keyword guileSyntax define-method define-generic define-accessor
syntax keyword guileFunction next-method no-method no-applicable-method no-next-method
syntax keyword guileSyntax enable-primitive-generic! primitive-generic-generic!
syntax keyword guileFunction generic-function-name generic-function-methods
syntax keyword guileFunction method-generic-function method-specializers method-procedure
syntax keyword guileFunction method-source

" Instances
syntax keyword guileFunction make make-instance
syntax keyword guileFunction class-of instance? is-a?
syntax keyword guileFunction shallow-clone deep-clone

" Slots
syntax keyword guileFunction class-slot-definition slot-definition-name
syntax keyword guileFunction slot-definition-options slot-definition-allocation
syntax keyword guileFunction slot-definition-getter slot-definition-setter
syntax keyword guileFunction slot-definition-accessor slot-definition-init-value
syntax keyword guileFunction slot-definition-init-form slot-definition-init-keyword
syntax keyword guileFunction slot-init-function
syntax keyword guileFunction slot-exists? slot-bound? slot-ref slot-set!
syntax keyword guileFunction slot-exists-using-class? slot-bound-using-class?
syntax keyword guileFunction slot-ref-using-class slot-set-using-class!
syntax keyword guileFunction class-slot-ref class-slot-set!
syntax keyword guileFunction slot-missing slot-unbound
" }}}

" Hash Tables {{{
syntax keyword guileSyntax make-hash-table alist->hash-table alist->hashq-table
syntax keyword guileSyntax alist->hashv-table alist->hashx-table
syntax keyword guileSyntax hash-table? hash-clear!
syntax keyword guileSyntax hash-ref hashq-ref hashv-ref hashx-ref
syntax keyword guileSyntax hash-set! hashq-set! hashv-set! hashx-set!
syntax keyword guileSyntax hash-remove! hashq-remove! hashv-remove! hashx-remove!
syntax keyword guileSyntax hash hashq hasv
syntax keyword guileSyntax hash-get-handle hashq-get-handle hashv-get-handle hashx-get-handle 
syntax keyword guileSyntax hash-create-handle hashq-create-handle hashv-create-handle hashx-create-handle 
syntax keyword guileSyntax hash-map->list hash-for-each hash-for-each-handle
syntax keyword guileSyntax hash-fold hash-count
" }}}

" Higher-Order Functions {{{
syntax keyword guileFunction const negate compose identity and=>
" }}}

" Hooks {{{
syntax keyword guileFunction make-hook
syntax keyword guileFunction hook? hook-empty? add-hook! remove-hook! reset-hook!
syntax keyword guileFunction hook->list run-hook
" }}}

" Internationalization {{{
syntax keyword guileFunction make-locale locale?
syntax keyword guileFunction string-locale<? string-locale>?
syntax keyword guileFunction string-locale-ci=? string-locale-ci<? string-locale-ci>?
syntax keyword guileFunction string-locale-upcase string-locale-downcase
syntax keyword guileFunction string-locale-titlecase
syntax keyword guileFunction char-locale<? char-locale>?
syntax keyword guileFunction char-locale-ci=? char-locale-ci<? char-locale-ci>?
syntax keyword guileFunction char-locale-upcase char-locale-downcase char-locale-titlecase

syntax keyword guileFunction locale-string->integer locale-string->inexact
syntax keyword guileFunction number->locale-string monetary-amount->locale-string

syntax keyword guileFunction locale-encoding
syntax keyword guileFunction locale-day locale-day-short locale-month locale-month-short
syntax keyword guileFunction locale-am-string locale-pm-string locale-time+am/pm-format
syntax keyword guileFunction locale-date+time-format locale-date-format locale-time-format
syntax keyword guileFunction locale-era-date+time-format locale-date-format
syntax keyword guileFunction locale-era-time-format locale-era locale-era-year
syntax keyword guileFunction locale-decimal-point locale-thousands-separator
syntax keyword guileFunction locale-digit-grouping

syntax keyword guileFunction locale-monetary-gouping locale-monetary-decimal-point
syntax keyword guileFunction locale-monetary-thousands-separator locale-currency-symbol
syntax keyword guileFunction locale-monetary-fractional-digits
syntax keyword guileFunction locale-currency-symbol-precedes-positive?
syntax keyword guileFunction locale-currency-symbol-precedes-negative?
syntax keyword guileFunction locale-currency-symbol-precedes-positive?
syntax keyword guileFunction locale-currency-symbol-precedes-negative?
syntax keyword guileFunction locale-positive-separated-by-space?
syntax keyword guileFunction locale-negative-separated-by-space?
syntax keyword guileFunction locale-monetary-positive-sign locale-monetary-negative-sign
syntax keyword guileFunction locale-positive-sign-position locale-negative-sign-position

syntax keyword guileFunction locale-yes-regexp locale-no-regexp

syntax keyword guileFunction gettext ngettext
syntax keyword guileFunction textdomain bindtextdomain bind-textdomain-codeset
" }}}

" Keywords {{{
" Order of guileKeyword matches matters. If the postfix syntax is defined first, then
" default syntax keywords match the #: part, but not the name of the keyword.
"
" Default keyword syntax
" match #: followed by any number of identifier characters
syntax match guileKeyword "#:[a-zA-Z0-9!$%&*+./:<=>?@^~_-]\+"

" Postfix keyword syntax
" match 1 or more identifier characters followed by a colon, but *not* followed by another
" identifier character.
syntax match guileKeyword "[a-zA-Z0-9!$%&*+./:<=>?@^~_-]\+:[a-zA-Z0-9!$%&*+./:<=>?@^~_-]\@!"

syntax keyword guileFunction keyword? keyword->symbol symbol->keyword
" }}}

" Lists {{{
syntax keyword guileFunction cons* copy-tree last-pair list-head
syntax keyword guileFunction append! reverse!
syntax keyword guileFunction list-cdr-set! delq delv delete delq! delv! delete!
syntax keyword guileFunction delq1! delv1! delete1! filter
syntax keyword guileFunction map-in-order
syntax keyword guileFunction merge merge! sorted? sort sort!
syntax keyword guileFunction stable-sort stable-sort! sort-list sort-list!
" }}}

" Meta {{{
syntax keyword guileFunction version effective-version
syntax keyword guileFunction major-version minor-version micro-version

syntax keyword guileFunction %package-data-dir %library-dir %site-dir %site-ccache-dir
" }}}

" Modules {{{
syntax keyword guileLibrarySyntax define-module use-modules import
syntax keyword guileLibrarySyntax export! re-export!

syntax keyword guileSyntax @ @@
syntax keyword guileFunction symbol-prefix-proc

syntax keyword guileFunction make-undefined-variable make-variable variable-bound?
syntax keyword guileFunction variable-ref variable-set! variable-unset! variable?

syntax keyword guileFunction current-module set-current-module save-module-excursion
syntax keyword guileFunction resolve-module resolve-interface module-uses module-use!
syntax keyword guileFunction reload-module module-variable module-add! module-ref
syntax keyword guileFunction module-define! module-set!
syntax keyword guileParameter user-modules-declarative?

syntax keyword guileSyntax provide require provided?
" }}}

" Numbers {{{
syntax keyword guileFunction centered/  centered-quotient  centered-remainder
syntax keyword guileFunction ceiling/   ceiling-quotient   ceiling-remainder
syntax keyword guileFunction euclidean/ euclidean-quotient euclidean-remainder
syntax keyword guileFunction round/     round-quotient     round-remainder

syntax keyword guileFunction logand logior logxor lognot logtest logbit? log-count 
syntax keyword guileFunction ash round-ash integer-length integer-expt bit-extract

syntax keyword guileFunction sinh cosh tanh asinh acosh atanh

syntax keyword guileFunction 1+ 1-
syntax keyword guileFunction inf inf?
syntax keyword guileFunction log10
syntax keyword guileFunction modulo-expt
syntax keyword guileFunction nan
" }}}

" Obect Properties {{{
syntax keyword guileFunction make-object-property object-properties
syntax keyword guileFunction set-object-properties! object-property set-object-property!
" }}}

" Parsing {{{
syntax keyword guileSyntax lalr-parser define-string-patterns define-peg-pattern
syntax keyword guileFunction peg-string-compile compile-peg-pattern
syntax keyword guileFunction match-pattern search-for-pattern
syntax keyword guileFunction peg:string peg:start peg:end peg:substring peg:tree
syntax keyword guileFunction peg-record? context-flatten keyword-flatten
" }}}

" Ports {{{
syntax keyword guileSyntax call-with-port
syntax keyword guileFunction port-closed?
syntax keyword guileFunction port-encoding set-port-encoding!
syntax keyword guileFunction port-conversion-strategy set-port-conversion-strategy!
syntax keyword guileFunction port-column port-line set-port-column! set-port-line!

syntax keyword guileFunction setvbuf force-output flush-all-ports drain-input
syntax keyword guileFunction seek ftell truncate-file

syntax keyword guileFunction read-line! %read-line write-line
syntax keyword guileFunction read-delimited read-delimited! %read-delimited!

syntax keyword guileFunction set-current-input-port set-current-output-port
syntax keyword guileFunction set-current-error-port
syntax keyword guileFunction with-input-from-port with-output-to-port with-error-to-port

syntax keyword guileFunction port-mode port-filename set-port-filename! file-port?
syntax keyword guileFunction file-encoding open-file with-error-to-file

syntax keyword guileFunction make-custom-binary-input-port make-custom-binary-output-port
syntax keyword guileFunction make-custom-binary-input/output-port make-soft-port
syntax keyword guileFunction %make-void-port

syntax keyword guileFunction char-ready? read-char peek-char unread-char unread-string
syntax keyword guileFunction newline write-char

syntax keyword guileFunction install-suspendable-ports! uninstall-suspendable-ports!
syntax keyword guileFunction current-read-waiter current-write-waiter

syntax keyword guileFunction make-buffered-input-port make-line-buffered-input-port
syntax keyword guileFunction set-buffered-input-continuation?!

syntax keyword guileFunction expect-strings expect
" }}}

" Procedures {{{
syntax keyword guileSyntax define-inlinable
syntax keyword guileFunction thunk? procedure setter
syntax keyword guileFunction procedure-name procedure-source procedure-documentation
syntax keyword guileFunction procedure-properties procedure-property
syntax keyword guileFunction set-procedure-properties! set-procedure-property!
syntax keyword guileFunction make-procedure-with-setter procedure-with-setter?

syntax keyword guileFunction pointer->procedure procedure->pointer
syntax keyword guileFunction foreign-library-function
" }}}

" Programs {{{
syntax keyword guileFunction program? program-code
syntax keyword guileFunction program-num-free-variable
syntax keyword guileFunction program-free-variable-ref program-free-variable-set!
syntax keyword guileFunction program-bindings make-binding
syntax keyword guileFunction binding:name binding:boxed? binding:index
syntax keyword guileFunction binding:start binding:end
syntax keyword guileFunction program-sources source:addr source:line
syntax keyword guileFunction source:column source:file
syntax keyword guileFunction program-arities program-arity
syntax keyword guileFunction arity:start arity:end arity:nreq arity:nopt
syntax keyword guileFunction arity:rest? arity:kw arity:allow-other-keys?
syntax keyword guileFunction program-arguments-alist program-lambda-list
" }}}

" Queues {{{
syntax keyword guileFunction make-q q? enq! deq! q-pop! q-push! q-length q-empty?
syntax keyword guileFunction q-empty-check q-front q-rear q-remove! sync-q!
" }}}

" R6RS {{{
syntax keyword guileLibrarySyntax install-r6rs!
" }}}

" Random {{{
syntax keyword guileFunction copy-random-state random random-state-from-platform
syntax keyword guileFunction random:exp random:hollow-sphere!
syntax keyword guileFunction random:normal random:normal-vector! random:solid-sphere! random:uniform
syntax keyword guileFunction seed->random-state datum->random-state random-state->datum
" }}}

" Reader {{{
syntax keyword guileSyntax read-enable read-disable read-set!
syntax keyword guileFunction read-hash-extend read-options read-syntax
" }}}

" REPLs {{{
syntax keyword guileFunction make-tcp-server-socket make-unix-domain-server-socket
syntax keyword guileFunction run-server spawn-server stop-server-and-clients!
syntax keyword guileFunction spawn-coop-repl-server poll-coop-repl-server
" }}}

" Records {{{
syntax keyword guileFunction record? make-record-type record-constructor record-predicate
syntax keyword guileFunction record-accessor record-modifier record-type-descriptor
syntax keyword guileFunction record-type-name record-type-fields
" }}}

" Regular Expressions {{{
syntax keyword guileFunction string-match make-regexp regexp-exec regexp? regexp-quote
syntax keyword guileFunction list-matches fold-matches
syntax keyword guileFunction regexp-substitute regexp-substitute/global

syntax keyword guileFunction regexp-match? match:substring match:start match:end
syntax keyword guileFunction match:prefix match:suffix match:count match:string
" }}}

" Strings {{{
syntax keyword guileFunction object->string
syntax keyword guileFunction string-null? string-any string-every string-split
syntax keyword guileFunction reverse-list->string string-tabulate string-join
syntax keyword guileFunction substring/shared substring/copy substring/read-only

syntax keyword guileFunction string-take string-drop string-take-right string-drop-right
syntax keyword guileFunction string-pad string-pad-right
syntax keyword guileFunction string-trim string-trim-right string-trim-both
syntax keyword guileFunction substring-fill! substring-move!

syntax keyword guileFunction string-compare string-compare-ci
syntax keyword guileFunction string= string<> string< string> string<= string>=
syntax keyword guileFunction string-ci= string-ci<> string-ci< string-ci> string-ci<=
syntax keyword guileFunction string-ci>=
syntax keyword guileFunction string-hash string-hash-ci
syntax keyword guileFunction string-normalize-nfd string-normalize-nfkd
syntax keyword guileFunction string-normalize-nfc string-normalize-nfkc

syntax keyword guileFunction string-index string-rindex string-prefix-length
syntax keyword guileFunction string-prefix-length-ci string-suffix-length
syntax keyword guileFunction string-suffix-length-ci
syntax keyword guileFunction string-prefix? string-prefix-ci?
syntax keyword guileFunction string-suffix? string-suffix-ci?
syntax keyword guileFunction string-index-right
syntax keyword guileFunction string-skip string-skip-right
syntax keyword guileFunction string-count string-contains string-contains-ci

syntax keyword guileFunction string-upcase! string-downcase!
syntax keyword guileFunction string-capitalize string-capitalize!
syntax keyword guileFunction string-titlecase string-titlecase!
syntax keyword guileFunction string-reverse string-reverse! string-append/shared
syntax keyword guileFunction string-concatenate string-concatenate-reverse
syntax keyword guileFunction string-concatenate/shared

syntax keyword guileFunction string-map! string-for-each-index
syntax keyword guileFunction string-fold string-fold-right
syntax keyword guileFunction string-unfold string-unfold-right

syntax keyword guileFunction xsubstring string-xcopy! string-replace string-tokenize
syntax keyword guileFunction string-filter string-delete string-replace-substring

syntax keyword guileFunction string->bytevector bytevector->string
syntax keyword guileFunction call-with-output-encoded-string

syntax keyword guileFunction string-bytes-per-char %string-dump

syntax keyword guileFunction get-string-n get-string-n!
syntax keyword guileFunction get-string-all get-line
syntax keyword guileFunction put-string unget-string

syntax keyword guileFunction call-with-output-string call-with-input-string
syntax keyword guileFunction with-output-to-string with-input-from-string

syntax keyword guileFunction string->pointer pointer->string
" }}}

" Symbols {{{
syntax keyword guileFunction symbol symbol-hash gensym
syntax keyword guileFunction list->symbol symbol-append string-ci->symbol
syntax keyword guileFunction list->symbol symbol-append
" }}}

" SXML {{{
syntax keyword guileFunction sxml-match
syntax keyword guileSyntax sxml-match-let sxml-match-let*
syntax keyword guileFunction xml->sxml sxml->xml sxml->string

syntax keyword guileFunction current-ssax-error-port with-ssax-error-to-port
syntax keyword guileFunction xml-token? xml-token-kind xml-token-head make-empty-attlist
syntax keyword guileFunction attlist-add attlist-null? attlist-remove-top attlist->alist
syntax keyword guileFunction attlist-fold
syntax keyword guileFunction define-parsed-entity! reset-parsed-entity-definitions!
syntax keyword guileFunction ssax:uri-string->symbol ssax:skip-internal-dtd
syntax keyword guileFunction ssax:read-pi-body-as-string ssax:reverse-collect-str-drop-ws
syntax keyword guileFunction ssax:read-markup-token ssax:read-cdata-body
syntax keyword guileFunction ssax:read-char-ref ssax:read-attributes
syntax keyword guileFunction ssax:complete-start-tag ssax:read-external-id
syntax keyword guileFunction ssax:read-char-data ssax:xml->sxml ssax:make-parser
syntax keyword guileFunction ssax:make-pi-parser ssax:make-elem-parser

syntax keyword guileFunction SRV:send-reply foldts post-order pre-post-order replace-range
syntax keyword guileFunction foldt foldts foldts* fold-values foldts*-values fold-layout
syntax keyword guileFunction nodeset? node-typeoof? node-eq? node-equal? node-pos filter
syntax keyword guileFunction take-until take-after map-union node-reverse node-trace
syntax keyword guileFunction select-kids node-self node-join node-reduce node-or
syntax keyword guileFunction node-closure node-parent sxpath 

syntax keyword guileFunction peek-next-char assert-curr-char skip-while skip-until
syntax keyword guileFunction next-token next-token-of read-text-line read-string
syntax keyword guileFunction find-string-from-port?

syntax keyword guileFunction apply-templates
" }}}

" Syntax Rules and Macros {{{
syntax keyword guileSyntax define-syntax-rule syntax-case syntax with-syntax
syntax keyword guileSyntax with-ellipsis quote-syntax defmacro
syntax keyword guileSyntax indentifier-syntax eval-when macroexpand
syntax keyword guileSyntax define-syntax-parameter syntax-parameterize
syntax keyword guileFunction datum->syntax syntax->datum
syntax keyword guileFunction identifier? bound-identifier=? free-identifier=?
syntax keyword guileFunction generate-temporaries syntax-source syntax-module
syntax keyword guileFunction syntax-sourcev syntax-local-binding
syntax keyword guileFunction syntax-locally-bound-identifiers
syntax keyword guileFunction make-variable-transformer
syntax keyword guileFunction make-syntax-transformer macro? macro-type macro-name
syntax keyword guileFunction macro-binding macro-transformer
" }}}

" Texinfo {{{
syntax keyword guileFunction call-with-file-and-dir texi-command-depth
syntax keyword guileFunction texi-fragment->stexi texi->stexi stexi->sxml
syntax keyword guileFunction sdocbook-flatten filter-empty-elements replace-titles
syntax keyword guileFunction add-ref-resolver! stexi->shtml urlify stexi-extract-index
syntax keyword guileFunction escape-special-chars transform-string expand-tabs
syntax keyword guileFunction center-string left-justify-string right-justify-string
syntax keyword guileFunction collapse-repeated-chars make-text-wrapper fill-string
syntax keyword guileFunction string->wrapped-lines stexi->plain-text stexi->tex
syntax keyword guileFunction module-stexi-documentation script-stexi-documentation
syntax keyword guileFunction object-stexi-documentation package-stexi-package-copying
syntax keyword guileFunction package-stexi-standard-titlepage package-stexi-generic-menu
syntax keyword guileFunction package-stexi-standard-menu package-stexi-extended-menu
syntax keyword guileFunction package-stexi-standard-prologue package-stexi-documentation
syntax keyword guileFunction package-stexi-documentation-for-include
" }}}

" Threads {{{
syntax keyword guileFunction all-threads current-thread call-with-new-thread
syntax keyword guileFunction thread? make-thread begin-thread
syntax keyword guileFunction join-thread thread-exited? cancel-thread
syntax keyword guileSyntax yield

syntax keyword guileFunction total-processor-count current-processor-count

syntax keyword guileFunction make-thread-local-fluid thread-local-fluid?

syntax keyword guileFunction system-async-mark
syntax keyword guileFunction call-with-blocked-asyncs call-with-unblocked-asyncs

syntax keyword guileFunction make-atomic-box atomic-box? atomic-box-ref atomic-box-set!
syntax keyword guileFunction atomic-box-swap! atomic-box-compare-and-swap!

syntax keyword guileFunction make-mutex mutex? make-recursive-mutex mutex-level
syntax keyword guileFunction lock-mutex unlock-mutex mutex-owner mutex-locked?

syntax keyword guileFunction make-condition-variable condition-variable?
syntax keyword guileFunction wait-condition-variable signal-condition-variable
syntax keyword guileFunction broadcast-condition-variable
syntax keyword guileSyntax with-mutex monitor

syntax keyword guileFunction future make-future future? touch

syntax keyword guileSyntax parallel letpar par-map par-for-each n-par-map n-par-for-each
syntax keyword guileSyntax n-for-each-par-map
" }}}

" Traps {{{
syntax keyword guileFunction add-trap! list-traps trap-name trap-enabled?
syntax keyword guileFunction enable-trap! disable-trap! delete-trap!

syntax keyword guileFunction with-default-trap-handler install-trap-handler!
syntax keyword guileFunction add-trap-at-procedure-call! add-trace-at-procedure-call!
syntax keyword guileFunction add-trap-at-source-location! add-ephemeral-stepping-trap!
syntax keyword guileFunction add-ephemeral-trap-at-frame-finish!

syntax keyword guileFunction trap-at-procedure-call trap-in-procedure
syntax keyword guileFunction trap-instruction-in-procedure trap-at-procedure-ip-in-range
syntax keyword guileFunction trap-at-source-location trap-frame-finish
syntax keyword guileFunction trap-in-dynamic-extent trap-calls-in-dynamic-extent
syntax keyword guileFunction trap-calls-to-procedure trap-matching-instructions

syntax keyword guileFunction trace-calls-to-procedure trace-calls-in-procedure
syntax keyword guileFunction trace-instructions-in-procedure call-with-trace

syntax keyword guileFunction vm-add-next-hook vm-add-apply-hook vm-add-return-hook
syntax keyword guileFunction vm-add-abort-hook 
syntax keyword guileFunction vm-remove-next-hook vm-remove-apply-hook
syntax keyword guileFunction vm-remove-return-hook vm-remove-abort-hook 
syntax keyword guileFunction vm-level-trace set-vm-level-trace!

syntax keyword guileFunction with-code-coverage coverage-data? coverage-data->lcov
syntax keyword guileFunction instrumented-source-files line-execution-counts
syntax keyword guileFunction instrumented/executed-lines procedure-execution-count
" }}}

" Types {{{
syntax match guileType "<[a-zA-Z0-9!$%&*+./:<=>?@^~_-]\+>"
syntax keyword guileType int8 uint8 int16 uint16 int64 uint64 float double
syntax keyword guileType complex-float complex-double
syntax keyword guileType int unsigned-int long unsigned-long short unsigned-short
syntax keyword guileType size_t ssize_t ptrdiff_t intptr_t uintptr_t void

syntax keyword guileSyntax define-wrapped-pointer-type define-foreign-object-type
syntax keyword guileFunction make-foreign-object-type
syntax keyword guileFunction sizeof alignof make-c-struct parse-c-struct
" }}}

" Vectors {{{
syntax keyword guileFunction vector-move-left! vector-move-right!
" }}}

" Vlists {{{
syntax keyword guileFunction vlist? vlist-null? vlist-cons vlist-head vlist-tail
syntax keyword guileFunction block-growth-factor
syntax keyword guileFunction vlist-fold vlist-fold-right vlist-ref vlist-length
syntax keyword guileFunction vlist-reverse vlist-map vlist-for-each
syntax keyword guileFunction vlist-drop vlist-take vlist-filter vlist-delete
syntax keyword guileFunction vlist-unfold vlist-unfold-right vlist-append
syntax keyword guileFunction list->vlist vlist->list
" }}}

" Vectors {{{
syntax keyword guileFunction restricted-vector-sort!
" }}}

" Vhashes {{{
syntax keyword guileFunction vhash? vhash-cons vhash-consq vhash-consv alist->vhash
syntax keyword guileFunction vhash-assoc vhash-assq vhash-assv
syntax keyword guileFunction vhash-deloc vhash-delq vhash-delv
syntax keyword guileFunction vhash-fold vhash-fold-right
syntax keyword guileFunction vhash-fold* vhash-foldq* vhash-foldv*
" }}}

" Vtables {{{
syntax keyword guileFunction make-vtable make-struct/no-tail struct? struct-ref
syntax keyword guileFunction struct-set! struct-ref/unboxed strect-set!/unboxed
syntax keyword guileFunction struct-vtable struct-vtable?
syntax keyword guileFunction vtable-index-layout vtable-index-printer
syntax keyword guileFunction struct-vtable-name set-struct-vtable-name!
syntax keyword guileFunction make-struct-layout
" }}}

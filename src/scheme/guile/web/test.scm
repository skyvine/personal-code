(define-module (skyler web test)
	#:use-module (web request)
	#:use-module (web response)
	#:use-module (web uri)

	#:use-module (skyler serialization test)
	#:use-module (skyler test util)
	#:use-module (skyler web serialization)
)

(define (both-false-or cmp lhs rhs)
	(or (not (or lhs rhs))
	    (cmp lhs rhs)))

(define example-uri (string->uri-reference "http://www.example.com:65535"))

(define uri (make-serialization-test "Serialize URI" example-uri))

(define request (make-serialization-test "Serialize Request"
	(build-request example-uri
	               version: '(2 . 0)
	               headers: '((custom-header . "custom value") (content-length . 0))
	               port:    65535
	               meta:    '((metadata      . "alist")))
))

(define response (make-serialization-test "Serialize Response"
	(build-response version:       '(2 . 0)
	                code:          599
	                reason-phrase: "Do I really need a reason?"
	                headers:       '((custom-header . "custom-value") (content-length . 0))
	                port:          9999)
))

(define all-tests (list request response))

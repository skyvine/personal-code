(define-module (skyler web serialization)
	#:use-module (oop goops)
	#:use-module (skyler standard)
	#:use-module (web request)
	#:use-module (web response)
	#:use-module (web uri)

	#:use-module ((skyler serialization) #:prefix sky.)

	#:export (<goops-request> <goops-response> <goops-uri>)
)

(define example-uri (string->uri-reference "http://www.example.com:8080"))

(define <goops-uri> (class-of example-uri))

(define-method (sky.serialize (obj <goops-uri>))
	(list '<goops-uri>
	      (uri-scheme obj)
	      userinfo: (uri-userinfo obj)
	      host:     (uri-host     obj)
	      path:     (uri-path     obj)
	      query:    (uri-query    obj)
	      fragment: (uri-fragment obj)
	      port:     (uri-port     obj)
))

(define-method (sky.%deserialize (inst <goops-uri>) init-vals)
	(apply build-uri (append init-vals (list validate?: #f))))

(define <goops-request>
	(class-of (build-request example-uri)))

(define-method (sky.serialize (obj <goops-request>))
	(list '<goops-request>
	      (sky.serialize (request-uri     obj))
	      method:        (request-method  obj)
	      version:       (request-version obj)
	      headers:       (request-headers obj)
	      meta:          (request-meta    obj)
	      port:          (request-port    obj)
))

(define-method (sky.%deserialize (inst <goops-request>) init-vals)
	(apply build-request (append init-vals (list validate-headers?: #f))))

(define <goops-response> (class-of (build-response)))

(define-method (sky.serialize (obj <goops-response>))
	(list '<goops-response>
	      version:       (response-version       obj)
	      code:          (response-code          obj)
	      reason-phrase: (response-reason-phrase obj)
	      headers:       (response-headers       obj)
	      port:          (response-port          obj)
))

(define-method (sky.%deserialize (inst <goops-response>) init-vals)
	(apply build-response (append init-vals (list validate-headers?: #f))))

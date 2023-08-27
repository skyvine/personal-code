" HTTP {{{
syntax keyword guileFunction string->header header->string known-header? header-parser
syntax keyword guileFunction header-validator header-writer declare-header!
syntax keyword guileFunction declare-opaque-header! valid-header? read-header parse-header
syntax keyword guileFunction write-header read-headers write-headers parse-http-method
syntax keyword guileFunction parse-http-version parse-request-uri read-request-line
syntax keyword guileFunction write-reuest-line read-response-line write-response-line
syntax keyword guileFunction make-chunked-input-port make-chunked-output-port

syntax keyword guileFunction request? request-method request-uri request-version
syntax keyword guileFunction request-headers request-meta request-port read-request
syntax keyword guileFunction build-request write-request read-request-body
syntax keyword guileFunction write-request-body request-accept request-accept-encoding
syntax keyword guileFunction request-accept-charset request-accept-language request-allow
syntax keyword guileFunction request-authorization request-cache-control
syntax keyword guileFunction request-connection request-content-encoding
syntax keyword guileFunction request-content-language request-content-length
syntax keyword guileFunction request-content-location request-content-md5
syntax keyword guileFunction request-content-range request-content-type request-date
syntax keyword guileFunction request-expect request-expires request-from request-host
syntax keyword guileFunction request-if-match request-modified-since request-if-none-match
syntax keyword guileFunction request-if-rannge request-if-unmodified-since
syntax keyword guileFunction request-last-modified request-max-forwards request-pragma
syntax keyword guileFunction request-proxy-authorization request-range request-referrer
syntax keyword guileFunction request-te request-trailer request-transfer-encoding
syntax keyword guileFunction request-upgrade request-user-agent request-via
syntax keyword guileFunction request-warning request-absolute-uri

syntax keyword guileFunction response? response-version response-code
syntax keyword guileFunction response-reason-phrase response-headers response-port
syntax keyword guileFunction read-response build-response adapt-version-response
syntax keyword guileFunction write-response response-must-not-include-body?
syntax keyword guileFunction response-body-port read-response-body write-response-body
syntax keyword guileFunction response-accept-ranges response-age response-allow
syntax keyword guileFunction response-cache-control response-connection
syntax keyword guileFunction response-content-encoding response-content-language
syntax keyword guileFunction response-content-length response-content-location
syntax keyword guileFunction response-content-md5 response-contentrange
syntax keyword guileFunction response-content-type response-date response-etag
syntax keyword guileFunction response-expires response-last-modified response-location
syntax keyword guileFunction response-pragma response-proxy-authenticate
syntax keyword guileFunction response-retry-after response-server response-trailer
syntax keyword guileFunction response-transfer-encoding response-upgrade response-vary
syntax keyword guileFunction response-via response-warning response-www-authenticate
syntax keyword guileFunction text-content-type?
" }}}

" URIs {{{
syntax keyword guileFunction build-uri uri? uri-scheme uri-userinfo uri-host uri-port
syntax keyword guileFunction uri-path uri-query uri-fragment string->uri uri->string
syntax keyword guileFunction declare-default-port! uri-decode uri-encode
syntax keyword guileFunction split-and-decode-uri-path encode-and-join-uri-path
syntax keyword guileFunction build-uri-reference uri-reference? build-relative-ref
syntax keyword guileFunction relative-ref? string->uri-reference string->relative-ref
" }}}

" Web Client {{{
syntax keyword guileFunction open-socket-for-uri http-request http-get http-put http-post
syntax keyword guileFunction http-head http-delete http-trace http-options
syntax keyword guileFunction x509-certificate-directory
syntax keyword guileFunction current-http-proxy current-https-proxy
" }}}

" Web Server {{{
syntax keyword guileFunction define-server-impl lookup-server-impl open-server read-client
syntax keyword guileFunction handle-request sanitize-response write-client close-server
syntax keyword guileFunction serve-one-client run-server http
" }}}

" File System {{{
syntax keyword guileFunction access?
syntax keyword guileFunction stat stat:dev stat:ino stat:mode stat:nlink stat:uid stat:gid
syntax keyword guileFunction stat:rdev stat:size stat:atime stat:mtime stat:ctime
syntax keyword guileFunction stat:atimensec stat:mtimenset stat:ctimensec stat:blksize
syntax keyword guileFunction stat:blocks stat:type stat:perms
syntax keyword guileFunction lstat readlink chown chmod utime delete-file copy-file
syntax keyword guileFunction sendfile rename-file link symlink mkdir rmdir opendir
syntax keyword guileFunction directory-stream? readdir rewinddir closedir sync mknod
syntax keyword guileFunction tmpnam mkstemp tmpfile mkdtemp dirname basename
syntax keyword guileFunction canonicalize-path file-exists? system-file-name-convention
syntax keyword guileFunction file-name-separator? absolute-file-name?
syntax keyword guileFunction file-name-separator-string 

syntax keyword guileConstant R_OK W_OK X_OK F_OK
" }}}

" Encryption {{{
syntax keyword guileFunction crypt getpass
" }}}

" Locales {{{
syntax keyword guileFunction setlocale
syntax keyword guileConstant LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES LC_MONETARY
syntax keyword guileConstant LC_NUMERIC LC_TIME
" }}}

" Networking {{{
syntax keyword guileConstant INADDR_ANY INADDR_BROADCAST INADDR_LOOPBACK 

syntax keyword guileFunction inet-netof inet-lnaof inet-makeaddr inet-ntop net-pton

syntax keyword guileFunction getaddrinfo addrinfo:flags addrinfo:socktype addrinfo:fam
syntax keyword guileFunction addrinfo:socktype addrinfo:protocol addrinfo:addr
syntax keyword guileFunction addrinfo:canonname
syntax keyword guileConstant AI_PASSIVE AI_CANONNAME AI_NUMERICHOST AI_NUMERICSER
syntax keyword guileConstant AI_ADDRCONFIG AI_V4MAPPED AI_ALL
syntax keyword guileConstant EAI_AGAIN EAI_BADFLAGS EAI_FAIL EAI_FAMILY EAI_NONAME
syntax keyword guileConstant EAI_NODATA EAI_SERVICE EAI_SOCKTYPE EAI_SYSTEM

syntax keyword guileFunction hostent:name hostent:aliases hostent:addrtype 
syntax keyword guileFunction hostent:length hostent:addr-list
syntax keyword guileFunction gethost gethostbyname gethostbyaddr
syntax keyword guileFunction sethostent gethostent endhostent sethost

syntax keyword guileFunction netent:name netent:aliases netent:addrtype 
syntax keyword guileFunction netent:net
syntax keyword guileFunction getnet getnetbyname getnetbyaddr
syntax keyword guileFunction setnetent getnetent endnetent setnet

syntax keyword guileFunction protoent:name protoent:aliases protoent:proto
syntax keyword guileFunction getproto getprotobyname getprotobynumber
syntax keyword guileFunction setprotoent getprotoent endprotoent setproto

syntax keyword guileFunction servent:name servent:aliases servent:serv
syntax keyword guileFunction getserv getservbyname getservbynumber
syntax keyword guileFunction setservent getservent endservent setserv

syntax keyword guileFunction make-socket-address sockaddr:fam sockaddr:path sockaddr:addr
syntax keyword guileFunction sockaddr:port sockaddr:flowinfo sockaddr:scopeid
syntax keyword guileFunction socket socketpair getsockopt setsockopt
syntax keyword guileConstant PF_UNIX PF_INET PF_INET6
syntax keyword guileConstant SOCK_STREAM SOCK_DGRAM SOCK_RAW SOCK_RDM SOCK_SEQPACKET
syntax keyword guileConstant SOL_SOCK IPPROTO_IP IPPROTO_TCP IPPROTO_UDP
syntax keyword guileConstant SO_DEBUG SO_REUSEADDR SO_STYLE SO_TYPE SO_ERROR
syntax keyword guileConstant SO_DONTROUTE SO_BROADCAST SO_SNDBUF SO_RCVBUF
syntax keyword guileConstant SO_KEEPALIVE SO_OOBINLINE SO_NO_CHECK SO_PRIORITY
syntax keyword guileConstant SO_REUSEPORT SO_LINGER IP_MULTICAST_IF IP_MULTICAST_TTL
syntax keyword guileConstant IP_ADD_MEMBERSHIP IP_DROP_MEMBERSHIP TCP_NODELAY TCP_CORK

syntax keyword guileFunction shutdown connect bind listen accept getsockname getpeername
syntax keyword guileFunction recv! send recvfrom! sendto 
" }}}

" Pipes {{{
syntax keyword guileFunction open-pipe open-pipe* close-pipe pipeline
syntax keyword guileFunction open-input-pipe open-output-pipe open-input-output-pipe
syntax keyword guileConstant OPEN_READ OPEN_WRITE OPEN_BOTH
" }}}

" Ports (Files) {{{
syntax keyword guileFunction porte-revealed set-port-revealed! fileno port-fdes fdopen
syntax keyword guileFunction fdes->ports fdes->inport fdes->outport primitive-move->fdes
syntax keyword guileFunction move->fdes release-port-handle fsync open
syntax keyword guileFunction open-fdes close close-fdes pipe dup->fdes dup->inport
syntax keyword guileFunction dup->outpurt dup dup->port duplicate-port redirect-port dup2
syntax keyword guileFunction port-for-each fcntl flock select
syntax keyword guileFunction add-fdes-finalizer! remove-fdes-finalizer!

syntax keyword guileConstant O_RDONLY O_WRONLY O_RDWR O_APPENT O_CREAT
syntax keyword guileConstant PIPE_BUF
syntax keyword guileConstant F_DUPED F_GETFD F_SETFD FD_CLOEXEC F_GETFL F_SETFL
syntax keyword guileConstant F_GETOWN F_SETOWN
syntax keyword guileConstant LOCK_EX LOCK_SH LOCK_UN LOCK_NB
" }}}

" Processes {{{
syntax keyword guileFunction chdir getcwd umask chroot getpid getgroups getppid
syntax keyword guileFunction getuid getgid getegid setgroups setuid setgid seteuid setegid
syntax keyword guileFunction getpgrp setpgid setsid getsid waitpid 
syntax keyword guileConstant WNOHANG WUNTRACED

syntax keyword guileFunction status:exit-val status:term-sig status:stop-sig
syntax keyword guileFunction system system* quit exit primitive-exit primitive-_exit
syntax keyword guileConstant EXIT_SUCCESS EXIT_FAILURE

syntax keyword guileFunction execl execlp execle primitive-fork nice
syntax keyword guileFunction setpriority getpriority setaffinity getaffinity
" }}}

" Runtime Environment {{{
syntax keyword guileFunction program-arguments command-line set-program-arguments
syntax keyword guileFunction getenv setenv unsetenv environ putenv
" }}}

" Signals {{{
syntax keyword guileFunction kill raise sigaction restore-signals
syntax keyword guileConstant SIGHUP SIGINT SA_NOCLDSTOP SA_RESTART

syntax keyword guileFunction alarm pause sleep usleep getitimer setitimer
syntax keyword guileConstant ITIMER_REAL ITIMER_VIRUTAL ITIMER_PROF
" }}}

" System Info {{{
syntax keyword guileFunction uname utsname:sysname utsname:nodename utsname:release
syntax keyword guileFunction utsname:version utsname:machine gethostname sethostname
" }}}

" Terminals and PTYs {{{
syntax keyword guileFunction isatty? ttyname ctermid tcgetpgrp tcsetpgrp
" }}}

" Time {{{
syntax keyword guileFunction current-time gettimeofday tm:sec tm:min tm:hour tm:mday
syntax keyword guileFunction tm:mon tm:year tm:wday tm:yday tm:isdst tm:gmtoff tm:zone
syntax keyword guileFunction localtime gmtime mktime tzset strftime strptime
syntax keyword guileFunction internal-time-units-per-second times
syntax keyword guileFunction tms:clock tms:utime tms:stime tms:cutime tms:cstime
syntax keyword guileFunction get-internal-real-time get-internal-run-time
" }}}

" Users {{{
syntax keyword guileFunction passwd:name passwd:passwd passwd:uid passwd:gid passwd:gecos
syntax keyword guileFunction passwd:dir passwd:shell
syntax keyword guileFunction getpwuid getpwnam setpwent getpwent endpwent setpw getpw
syntax keyword guileFunction group:name group:passwd group:mem group:gid
syntax keyword guileFunction getgrgid getgrname getgrent setgrent endgrent setgr getgr
syntax keyword guileFunction getlogin
" }}}

# Purpose
This repository contains code that I use for my personal machine. It's mostly things to
maintain my system configuration but also contains some general-purpose code that I find
useful. I also like thinking about code readability, and try to make this code as
readable as possible (in term of style, documentation, and documentation style).

# Organization
Typically, repositories for scripting languages have a structure that mirror their install
location (eg, directory paths that represent the module path). This repository pays some
heed to this convention, but does not follow it strictly. This is because this repository
is simply a collection of scripts that I find useful, and so is not necessarily tied to,
for example, on particular implementation or even one particular programming language
(although in practice, it currently is).

For libraries, the **in-tree path** is `src/{language}/{implementation}/{project}`.
Note that implementation might be a real implementation, such as GNU Guile, or it might
refer to a standard that describes multiple implementations, such as R7RS. The
**installation path** is `skyler/{project}`, with 2 exceptions. When the code is written
to a standard, this is included as the second component, for example
`skyler/r7rs/{project}`. The inclusion of this component is to disambiguate modules
written generically from those written specifically, which sometimes have the same name.
For example, there is a `(skyler standard)` module which contains routines that I expect
to be always available. The one written in R7RS makes sense regardless of implementation,
while the one written in GNU Guile uses Guile-specific features, and re-exports everything
from the R7RS version of the module. The other exception is the `base` project, which
contains code that should be installed to the root of the namespace.

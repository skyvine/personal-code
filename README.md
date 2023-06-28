# Purpose
This code is for my personal machine. My main concern with my machine is having a unified
programming interface. This means that I should be able to accomplish everything in my
day-to-day with guile, dropping into C\* where appropriate. See the README in
`src/scheme/guile/guix/` for more on this, including an explanation of why this is a
separate repository and I'm not just working in Guix directly.

\* I really like rust too, but it seems tricky to integrate Rust with Guile as deeply as
C already is. On the table though.

# License
Most of the sofware in this repository is licensed under the Affero GNU Public License,
version 3 or any later version.

I default to using the AGPL 3 or later unless there is a strong reason to downgrade to the
plain GPL or the LGPL. Some individual files may use different (AGPL-compatible) licenses
if the source code is mostly borrowed from another project. The top of every source file
should have language specifying its license; if you find any file is missing this lanugage
please [open an bug](https://todo.sr.ht/~skyvine/personal-code) and I will remediate the
situation as quickly as possible.

[The FSF has published advice on license selection.](https://www.gnu.org/licenses/license-recommendations.html)
I generally agree with this advice, except that they recommend using the AGPL only when it
"seems likely" that the software will be used on a server. I don't see any reason to make
a judgement about the likelihood here - if the work is licensed under the AGPL and never
gets used on a server, then it is effectively licensed on the GPL and all is well. If it
is licensed under the GPL and is unexpectedly used on a server, recovery is difficult, if
it is even possible.

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

## Branches

The "trunk" branch is where finalized commits are stored. These are all finalized and
signed by my PGP key. Other branche are for WIP commits. These are not signed and are
subject to change (amending and force-pushing) at any time. Each side branch contains a
note at the top of its README explaining its purpose.

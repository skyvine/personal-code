# Purpose
This code is for my personal machine. My main concern with my machine is having a unified
programming interface. This means that I should be able to accomplish everything in my
day-to-day with guile, dropping into C\* where appropriate.

* I really like rust too, but it seems tricky to integrate Rust with Guile as deeply as
  C already is. On the table though.

# License
All sofware in this repository is licensed under the Affero GNU Public License, version 3
or any later version.

I default to using the AGPL 3 or later unless there is a strong reason to downgrade to the
plain GPL or the LGPL. Non-GNU licenses are off the table.

[The FSF has published advice on license selection.](https://www.gnu.org/licenses/license-recommendations.html)
I generally agree with this advice, except that they recommend using the AGPL only when it
"seems likely" that the software will be used on a server. I don't see any reason to make
a judgement about the liklihood here - if the work is licensed under the AGPL and never
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
contains code that should be installed to the root of the namespace (currently, this is
only the aforementioned `standard.scm`).

# Notes: Style and other decisions
This is not exhaustive or definitive. I feel the need to justify some of my decisions
because they seem particularly abnormal. I want to record my thought process for some
decisions because I don't want to forget my reasons. In other cases, I have a tendency
to go back and forth on the decision and I want to actually remain consistent, so having
it written down helps.

## Maximum line length
I use 90 characters as the limit. This is a completely arbitrary decision, 90 characters
lets me fit 2 side-by-side file on my monitor with a little bit of breathing room.

## Keyword Syntax
I load srfi-88 style keywords, meaning that `example:` (postfix syntax) is just as much a
keyword as `#:example` (default syntax). Both syntaxes are used.

The default syntax is needed in `define-module` declarations to prevent an error, because
the reader option has not been set until *after* the `define-module` form has been
evaluated (the postfix syntax works in some cases, the reader is global state).

Otherwise, keywords use the default syntax when they are valued and the postfix syntax
when they are labels (eg, keyword arguments to a define\* function). This is illustrated
simply in a GOOPS class declaration:

```scheme
(use-modules (srfi srfi-88) (oop goops))
(define-class <example>
	(some-data init-keyword: #:some-data init-value: '()))
```

And can also be seen in a define\* declaration:

```scheme
(define* (example key: some-argument some-other-argument #:allow-other-keys)
	(do-all-the-stuff!))
```

Using the postfix syntax for labels indicates to the reader that the keyword is directly
linked to the following value(s), due to the meaning of a postfix colon character in
English prose. Using the default syntax for values avoids this misleading indication.

## Leading blankspace
I use tabs for indentation and spaces for alignment. This is advantageous because it
makes use of a user's tab setting's effectively. When a new line should add an extra
level of indentation vs aligning with something above it is somewhat arbitrary.
Generally, I use indentation for scope-related constructs and alignment if there's just a
long function call.

I will sometimes use indentation to avoid excessively long lines. Not 100% sure this hack
is OK, but I'm comfortable with it for the moment.

### Alignment
I err on the side of over-aligning code vs under-aligning it. The primary reason is just
because it looks nice and feels better to read code that is aligned. I comfort myself
with a finding in Hansen, Goldstone, and Lumsdaine (2013)\* that programmers are more
likely to mentally process code incorrectly when it is not aligned\*\*.

\* Hansen, Goldstone, and Lumsdaine. 2013. What makes code hard to understand?
https://arxiv.org/pdf/1304.5257.pdf

\*\* As we all know, one finding in one study is definitive proof of objective truth.

## Closing parentheses
I generally agree that closing parentheses should not be placed on a separate line. It
creates visual noise and lengthens files. However, it is annoying to have to pick through
parentheses to add new code\*, so in cases where modification is likely I will place them
on a separate line. There are many cases where this always happens, such as the import
section of a library definition. Informally, I tend to place the close parethesis on a
separate line if I'm not confident that a function is finished yet, but place it on the
same line if it seems complete and bug-free\*\*.

\* I know that you can do things like go to the relevant open parenthesis and jump to the
correct one, but this disrupts my flow. I am also aware that there are more powerful
structured editing tools, but I have not yet invested time into them.

\*\* Bug-free is a completely realistic goal I don't know what you're talking about.

## Namespacing Symbols
When writing libraries, I do not pre-namespaces symbols For example, an accessor for a
member named `member` in a class named `class` would simply be `member`, not
`class-member`. Guile provides convenient facilities for dependent modules to rename
symbols in an appropriate matter, and I consider it better to leave that decision up to
the user rather than enforcing my own namespacing convention.

When importing libraries, I namespace with the prefix `project-name.`. This help me keep
track of what projects I'm dependent on in which ways. For example, when importing form
`(gnu packages *)` I use `#:prefix guix.` rather than `#:prefix gnu.` because guix is the
project that the code (eg, the package definition) is being imported from. This is
followed most of the time but is not completely strict, for example when importing the
licences module I use the `license.` prefix for consistency.

It is common to use a colon for namespacing in scheme, but this causes confusion with
keywords that use the postfix syntax. First, it can confuse syntax highlighting when
referencing members unless care is taken to look ahead. Second, in the `#:prefix` form,
the syntax is indistinguishable to the point that in some cases guile will throw an error
because the argument is read as a keyword, and #:prefix must be given a symbol.

Most imports use a prefix. The main exceptions are `(skyler standard)` and anything that
is importand from the language or the implementation's standard libraries. Other
exceptions need to be made for technical reasons, for example importing `(guix gexp)`
with a prefix breaks the `#~` syntax.

# Purpose
This code is for my personal machine. My main concern with my machine is having a unified
programming interface. This means that I should be able to accomplish everything in my
day-to-day with guile, dropping into C\* where appropriate.

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
contains code that should be installed to the root of the namespace.

# Notes: Style and other decisions
This is not exhaustive or definitive. I feel the need to justify some of my decisions
because they seem particularly abnormal. I want to record my thought process for some
decisions because I don't want to forget my reasons. In other cases, I have a tendency
to go back and forth on the decision and I want to actually remain consistent, so having
it written down helps.

## Documentation
Documentation will be placed alongside code inside of source files and will use markdown
formatting. While there is currently no workflow for extracting comments into some
external document format (info, html, etc), it will be written with the assumption that
this workflow will someday be put into place.

Documentation will be written with the assumption that the program has an expert
understanding of the programming language and no knowledge of the project: everything that
is project-specific must be explained. This explanation may be given by pointing the
reader to a different module which explains the required concepts (for example, a module
which uses the class conventions need not re-explain the conventions, but will inform the
reader that the documentation in the `(skyler class-conventions)` module is relevant).

## File Layout

### Header
The top of a file will contain comments declaring the copyright and license covering the
file. Nothing will precede these comments, with the exception of a `#!` directive for
executable script, and only because it is technically necessary for the directive to be at
the start of the file.

After the legalese, module-level documentation will be placed in comments. This will
describe the purpose of the module and conceptual information, but does not descibe the
API in detail; the API is described in the exports section.

Next, the file will set the namespace. This means either a `define-module` form for
guile-specific scripts, a `define-library` form for generic r7rs scripts, or the
equivalent form for a different implementation. In the case of a `define-module` form, all
imports and exports will take place here, with the exception of internal modules which set
the keyword syntax, because setting this syntax may cause errors in other modules.
Syntax-setting modules will be imported *immediately* after the namespace-setting form.

#### Imports
Imports will use a prefix of the form `<project>.`, where `<project>` is the (potentially
abbreviated) name of the project that the module comes from. For example, `guix.` is used
for modules that come from GNU Guix, and `sky.` for my personal modules. There are 4
exceptions to this rule which follow:

1. Built-in modules: if the implementation itself provides the module than no prefix is
   used.
2. Related modules: parent modules, sibling modules, and child modules (including the
   children of siblings) do not need to be prefixed.
3. Pre-established conventions: if there is a commonly used convention for prefixing a
   particular module, then that prefix *may* be used, however the `.` character will still
   be used as the separator. For example, when importing the `(guix licenses)` module, the
   prefix `license.` is used following the convention of `license:` used in the GNU Guix
   project. See below for further discussion on the use of `.` instead of `:`.
4. Technical requirements: for some modules, imposing a prefix reduces technical utility.
   For example, importing `(guix gexp)` with a prefix breaks the `gexp`/`ungexp` syntax
   (`#~` and `#$`). In these cases, a selector will be used to import only those symbols
   which are technically necessary.

It is common to use a colon for namespacing in scheme, but this causes ambiguity with
keywords that use the postfix syntax. Syntax highlighters may mistakenly highlight
namespaces as keywords if not programmed carefully, and in some cases this can result in
an interpreter error preventing program execution (most commonly in the argument to
`#:prefix` when importing a module). Therefore, the `.` character is used. While this
technical limitation is the primary motivation for using `.`, this also has the benefit
of being more familiar to developers who typically use more popular languages such as c,
c++, java, javascript, python, etc. Though it should be acknowledged that the semantics
are quite different from some of these languages (python uses a `.` to access members of a
namespace, but c++ uses `::` for namespaces and `.` for object members - and in either
case, the `.` is a language construct rather than part of a symbol name).

#### Exports
Exports will contain API documentation. This is so that users of the module can refer only
to the header for typical use, and look at the body of the file only if they need to
understand or modify implementation. In this way, the header of a scheme file can serve a
similar purpose to a c/c++ header.

Libraries will not pre-namespaces symbols For example, an accessor for a member named
`member` in a class named `class` would simply be `member`, not `class-member`. Guile
provides convenient facilities for dependent modules to rename symbols in an appropriate
matter, and it is better to leave that decision up to the user rather than enforcing a
namespacing convention which may or may not suit their needs.

### Body
The body of a file will first and foremost be organized in such a way that the
organization seems both sensible and useful to the author. Preference will be given to the
ergonomics of those writing and modifying the file, rather than those reading the file,
because pure users should not need to refer to any information outside of the header in
order to be successful. If they do need to read the body, this is a documentation bug.

Internal (non-exported) functions will contain a docstring explaining their usage.
Exported functions will *not* explain their usage here as their usage is documented in the
exports section. In either case, functions will contain comments explaining conceptual
information useful to understanding their implementation (but not reiterate conceptual
information from the module documentation).

## Maximum line length
Lines will not exceed 90 characters. Line length is completely arbitrary; 90 characters
lets me fit 2 side-by-side file on my monitor with a little bit of breathing room. For the
purpose of this limit, tabs are counted as 2 characters (regardless of their starting
location on the line).

## Keyword Syntax
srfi-88 style keywords are used, meaning that `example:` (postfix syntax) is just as much
a keyword as `#:example` (default syntax). Both syntaxes are used.

The default syntax is needed in `define-module` declarations to prevent an error, because
the reader option has not been set until *after* the `define-module` form has been
evaluated (the postfix syntax works in some cases, the reader is global state).
Additionally, setting this option before loading files from other projects can cause those
files to break (for example, if the external file uses the common convention of a trailing
colon for prefixes).

Otherwise, keywords use the default syntax when they are values and the postfix syntax
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
linked to the following value(s), due to the usage of postfix colons in the popular Python
programming language. Using the default syntax for values and flags avoids this misleading
implication.

## Leading blankspace
Tabs will be used for indentation and spaces for alignment. This is more taxing for the
writer, but can be more ergonomic for the reader. The number of spaces that we use for
indentation is somewhat arbitrary (there is no objectively "correct" answer), and
different people find different amounts of space more comfortable to read. This
indentation, for example inside the body of a c function, is a distinct concept from
alignment. With alignment, there is a correct number of spaces for all readers. If your
signature makes the line too long, then everyone should see the arguments align:

```c
int function(int  this,
             int  is,         // here we want alignment, regardless of indentation size
             char so,
             long loooong) {
	return 3;                   // here we want per-user indentation levels
}
```

The implications of tabs vs spaces might be visible above, depending on how the text
viewer that you are currently using displays tabs: if the tab character at the beginning
of the `return` line is 2 characters in width, the comments will be aligned; otherwise
they will not be (in practice, it is rare to want to align coments at different levels
of indentation as in this example).

There is a wrinkle to using tabs in this way, because tabs are not fixed-width even within
the context of one editor that has a particular setting. A tab character does not
currently mean "insert a fixed amount of blankspace", it means "jump to the next column
that is an even multiple of a fixed amount". This meaning is no longer useful in the
modern day, so I use a patched version of neovim that always resolves tabs to the same
width. The patch can be found in the `patches` directory of this repository.

### Alignment
I err on the side of over-aligning code vs under-aligning it. There is some justification
for this based on a paper by Hansen, Goldstone, and Lumsdaine\*, where they found that
programmers are more form an inaccurate mental model of program execution when similar
adjacent statements are unaligned. This is only one result from one study, but it is
reinforced by my personal experience, and at some point I have to make a decision.

\* Hansen, Goldstone, and Lumsdaine. 2013. What makes code hard to understand?
https://arxiv.org/pdf/1304.5257.pdf

## Closing parentheses
It is not generally useful to place closing parentheses on separate lines, as this creates
visual noise and lengthens files. However, it is not ergonomic to pick through parentheses
when modifying code\*, so in cases where modification seems likely parentheses will be
placed on a separate line. There are some cases where this always happens, such as the
import section of a library definition.

Informally, I tend to place the close parethesis on a separate line if I'm not confident
that a function is finished yet, but place it on the same line modification seems
unlikely or has historiaclly been infrequent.

\* There are arguments that structured editing solves this problem at that may indeed be
   a better solution, but it is not one that I have (yet) invested time into pursuing.

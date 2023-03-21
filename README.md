# Purpose
This code is for my personal machine. My main concern with my machine is having a unified
programming interface. This means that I should be able to accomplish everything in my
day-to-day with guile, dropping into C\* where appropriate.

* I really like rust too, but it seems tricky to integrate Rust with Guile as deeply as
  C already is. On the table though.

# Notes: Style and other decisions
This is not exhaustive or definitive. I feel the need to justify some of my decisions
because they seem particularly abnormal. I want to record my thought process for some
decisions because I don't want to forget my reasons. In other cases, I have a tendency
to go back and forth on the decision and I want to actually remain consistent, so having
it written down helps.

## Maximum line length
I use 90 characters as the limit. This is a completely arbitrary decision, 90 characters
lets me fit 2 side-by-side file on my monitor with a little bit of breathing room.

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
When writing libraries, I do not pre-namespaces symbols. Guile provides convenient
facilities for dependent modules to rename symbols in an appropriate matter, and I
consider it better to leave that decision up to the user rather than enforcing my own
namespacing convention.

When importing libraries, I namespace with the prefix `project-name:`. This help me keep
track of what projects I'm dependent on in which ways. For example, when importing form
`(gnu packages *)` I use `#:prefix guix:` rather than `#:prefix gnu:` because guix is the
project that the code (eg, the package definition) is being imported from. This is
followed most of the time but is not completely strict, for example when importing the
licences module I use the `license:` prefix for readability.

Most imports use a prefix. The main exceptions are `(skyler standard)` and anything that
is importand from the language or the implementation's standard libraries. Other
exceptions need to be made for technical reasons, for example importing `(guix gexp)`
with a prefix breaks the `#~` syntax.

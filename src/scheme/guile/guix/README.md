# Purpose

This project contains code supporting my Guix configuration. I am keeping this in my own
repository instead of working directly in Guix for a few reasons:

1. It is not clear to me that my goals and the goals of Guix are 100% aligned. While the
   project clearly loves doing everything in guile, I want to build a puritanical machine
   - to the point of not having `sh` installed on my computer and building a
   (neo)vim-based editor that is natively scripted in guile. There are good engineering
   reasons not to be committed to such an extreme vision, and I do not want to force my
   desires onto anyone else. However, if anything I do is of general interest then I am of
   course happy to contribute the code to the upstream project under their licensing
   terms. I am also happy to keep my opinionated and questionable decisions in a personal
   repository.
2. While this project is grounded in achieving a practical outcome - building a machine
   that is completely focused on lisp - my main motivation for embarking on this project
   is to completely understand how my computer works. This understanding will be a natural
   outcome of building the machine, because I will have to examine each component of the
   system and determine how to "lispify" it (or determine that the large amount of work
   previously done on Guix and Guile provide sufficient "lispification"). I tend to be
   more motivated by learning things than doing things, but I have found that learning
   happens better when it is grounded in a practical (though admittedly contrived)
   objective.
3. While I have used Guix for a number of years, most of what I've actually done with it
   is modify packages with custom patches, create trivial services specific to my
   environment, etc. I am just starting to explore Guix's internals, and while this does
   involve diving into the Guix repository, I want to keep all of my code in a separate
   location to avoid making a mess, until I better understand Guix's internal structure,
   which things are appropriate to include in the main repository, and where in the
   repository they belong.

# Filemap

## README.md

You Are Here

## collections.md

Collections of system components organized in a way that is sensible to me and useful for
my purpose. For example, there are a few lists of services, including (among others)
global services, normal networking services, and qubes networking services. Global
services need to be on every machine that I might want to build (ranging, for example,
from a rescue ISO to a development desktop). Normal networking services include the normal
tools that people expect on modern systems (for example, fetching the IP address through
a DHCP server). However, I sometimes work inside of Qubes VMs, which have a peculiar
method of configuring the network. This motivated me to separate the networking services
from the global services even though I want most everything I build to have at least the
potential to connect to a network.

Guix provides many collections which are suitable for day-to-day use, such as the
`%desktop-services` list. From a practical perspective, configuring a machine using these
collections makes more sense. Some customization may be needed, and Guix provides
facilities to customize them dynamically. From an engineering perspective, relying on the
definitions provided upstream will result in a more stable system because they will keep
those collections in sync with upstream changes (for example, there have been a few cases
where a singleton instance of a service has been replaced with a particular service type,
which has led to deprecation warnings in this repository).

However, as noted above my primary motivation here is to learn, not to build a perfectly
engineered system. This is a demonstration of why it makes sense for me to keep code in a
separate repository first, and only prepare upstream patches for things which might
legitimately be of general interest.

## home.scm

My home configuration

## pack.scm

Defines a manifest to pass into `guix pack` which contains things that I want to install
on foreign distros. Limited to command-line utilities.

## packages.scm

Contains package definitions that I want for my system and are not included upstream.
These are the things that I am most uncomfortable keeping in a separate repository, but I
have not put them upstream for various reasons. One reason that they all share in common
is that I cannot in good conscience commit to maintaining a package at this point it time,
as I am in a transitionary period in my life and do not know what my future
responsibilities will be.

For Aetf's version of libtsm/kmscon, I did actually send an email to the Guix development
team in case they were interested, but have not at time of writing received a reply. I
suspect that they might not want to include it in their repository. They are actually
pulling from Aetf's repository of kmscon, but the specified commit is from when dvdhrm
maintained it. As far as I can tell Aetf only forked to do some personal work and does not
intend to be a permanent maintainer. However, they also introduced significant changes to
the repository such as converting the build system from autotools to meson. This
introduces instability with no guarantee of support. Guix uses kmscon in the installer
image, where stability is critical, and it seems unlikely that many people are using
kmscon as their primary display manager, so the extra features that Aetf added would not
provide much benefit. All of the previous reasoning also applies to the patches that I
added to it.

For haunt-0.3.0, I don't think this has actually been released by the developer, the tag
just exists. I defined it because the `--host` argument is useful when testing a website
across VMs. I assume that it will be updated in the Guix repository once it is a stable
release, rather than a development branch.

For neovim-solarized8, the only reason is my inability to responsibly commit to
maintenance. It is still under active development, and the most recent release created
separate tarballs for vim and neovim, where they were previously unified, so maintenance
is not necessarily trivial.

## services.scm

This only exists for the version of kmscon I'm using, as above I would be happy to prepare
an upstream patch to update the Guix service definition if it were reasonable to include
the code upstream.

## systems.scm

Functions for creating systems I tend to use with minimal effort at creation time. I do
not think that these are in any sense general interest, they are specific configurations
of the machines that I work on.

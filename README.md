# rst2packt

This repository contains the scripts I wrote to help me write a book about
functional programming in PHP that was commandited by Packt Publishing. The
result of my work was published in February 2017.

The book starts with a gentle introduction to functional programming and presents
the related concepts in PHP. More advanced topics like function composition,
functors, applicative, and monads are also discussed. Functional programming is
also presented through the lense of performance and testing.
You can find more information on the dedicated webpage: [Functional PHP](book).

If you want more information about the writing process itself, you can have a
look at the blog post I wrote: [Writing a book: Functional PHP](blog).

[book]: https://www.packtpub.com/application-development/functional-php
[blog]: http://gilles.crettenand.info/blog/programming/2017/23/02/Writing-a-book

## Disclaimer

Those scripts are published as is. It worked fine for me with my particular setup,
but there is no guarantee that you will be able to use it without doing some
adaptations first.

As the scripts were not written with reusability in mind, they rely on a list of
assumptions, for example about the directory structure. Currently, they are also
written for a book about PHP in mind, but it should be possible to adapt them
for any language.

## Installation

You can either add the repository as a submodule of your own project if you are
using git, or simply download the repository and add it to your book folder.

Once you have the content of the repository, you need to either copy or make a
symlink of the `Makefile` and `watch` files from the `rst2packt` directory to
the root folder.

### Directory structure

The scripts expect the following directory structure:

```
<project root>
|-- rst2packt
|-- src
|   +-- vendor
|-- assets
|-- dist
+-- .builds
    |-- assets
    |-- outputs
    +-- src
```

* The root contains the rst files, the `Makefile`, and the `watch` script
* `rst2packt` contains the content of this repository
* `src` contains the source code for the book
* `src/vendor` contains packages installed via composer
* `assets` contains the various media for the book
* `dist` contains the generated odt and zip files
* `.builds` and its children contain build artifacts

It is possible to use a different structure, but the Makefile and some of the
other scripts will need to be adapted.

## Usage

`rst2packt` uses a `Makefile` to do most of its work. Here is a list of the possible targets:

* `html` creates a `document.html` file in the `dist` directory with all the book content.
* `pdf` creates a `document.pdf` file in the `dist` directory with all the book content.
* `odt` creates a separate `.odt` file for each chapter in the `dist` directory.
* `zip` creates a `zip` archive for each chapter containing the `.odt` file, the assets, and the source code in the `dist` directory.
* `lint` run `php` in linting mode on all files in the `src` directory
* `output` try to compute the output of the source files for each line and add it as a comment inside the file itself. This only partially work and was finally not used.
* `clean` delte everything in the `.builds` and `dist` directories.

To execute a target, simply run `make <target>`, for example `make zip` to create an archive of all chapters in the `dist` directory. If you run `make` without any target, it will create the HTML file.

There is also a `watch` script that you can run. It will watch for any changes in the project. If a change is detected, it will recreate the HTML file. It also launches `browser-sync` so that your browser can automatically be updated with the latest content.

## Issues and contributions

If you find any issues, I urge you to use the [bugtracker](bugs). Since my book
is now published, I make no promise to fix those for you, but I will try my best.
Pull requests are also welcome.

[bugs]: https://github.com/krtek4/rst2packt/issues

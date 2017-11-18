# Contribution #

Contribution means helping the project get bigger and better, by any manner.  
If this is what your'e truly looking for, than you've come to the right place!

## Short Brief ##

### What is this file? ###
It is a set of guidence rules for developers who'd like to contribute to this repo.  
API changes, versions go forward but sometimes documentation is not, unfortunately.  
To address those issues and allow developers to contribute good, quality code - This file must exist and always be up to date.

### Dear Contributors ###
First of all, thank you for taking your time even considering contributing to this repo.  
It is extremely improtant to us that you, simple users or continous collaborators, 
contribute to this project in a combined effort to make it greater, stable than ever before.  

## Subbmiting Issues ##
Requests for new features and bug reports keep the project moving forward.

### Before you submit an issue ###
* Please make sure your'e using the latest version of Arduino CMake. 
Currently it's the one in the [master](https://github.com/arduino-cmake/arduino-cmake) branch,
but this will be updated once a version-release standard will be applied.
* Search the [issue list](https://github.com/arduino-cmake/arduino-cmake/issues?utf8=%E2%9C%93&q=is%3Aissue)
(including closed ones) to make sure it hasn't already been reported.

### Subbmiting a good issue ###
Issues can be subbmited with a very short description, but that would make the life of the developers addressing it
very hard, leading to unresolved issues due to lack of information.  
Here is a set of rules you should apply to **every** issue you submit:
* Give the issue a short, clear title that describes the bug or feature request
* Include your Arduino SDK version
* Include your Operating System (No need to specify exact Linux version (Ubuntu, Fedora, etc.) - Linux is just enough)
* Include steps to reproduce the issue
* If the issue regards a special behavior, maybe related to a specific board - Please tell us all you know about it 
and put some links to external sources if those exist. Not all of the developers are Arduino experts, and in fact there 
are so many types of boards and platforms that there being an "Arduino Expert" isn't even real.
* Use markdown formatting as appropriate to make the issue and code more readable.

## Code Contribution

### Code Style
Like pretty much every project, ArduinoCMake uses it'ws own coding style which ensures that everybody can easily read and change files without the hassle of reading 3 different indention styles paired 4 ways of brace spacing.

While we believe, that the coding style you are using benefits you, please try and stick to the current style as close at possible. It is far from perfect (and we ourselves don't like every part that has grown from the project's
past) but it is sufficient to be a common set of rules we can agree on.

For the most basic part, make sure your editor supports `.editorconfig`. 
It will
take care of the greatest hassle like indention, new lines and linebreaks at the end of a file. As for spacing, naming conventions etc. look at the existing code to get an idea of the style. If you use an `IDEA` based IDE (for example
`CLion`)
chances are that the autoformatting functionality will take care of things due to the project's `codeStyleSettings.xml` residing in the repository.

### Versioning
While in the past the project barely had a proper verioning scheme, we're now trying to incorporate [semantic versioning](http://semver.org/spec/v2.0.0.html).
That benefits both developers and users, as there are clear rules about when to bump versions and which versions can be considered compatible.

### Bug fixes
If you have found and corrected a bug within a certain release, please make sure to PR into the correct release branch. Release branches are named `release/vM` where `M` is the major version (thus according to *semver*
backwards-compatible)
of the release. Make sure you are on the latest commit of that branch.

While `master` also contains the latest stable release, **do not PR directly into master please**. Use the corresponding release branch and let us take care of merging, should it be the latest branch.

### Feature additions
To ensure your contribution makes it into the mainline codebase, always check the `develop` branch for the next targeted release. Make sure your contribution is on par with that branch and PR features back into `develop`. This strategy should be the right one for most users. If you want to make further additions to a feature currently under development, you can also PR into the corresponding feature branch.

### Breaking changes
Breaking changes require the release of a new major version according to
*semver*
rules. So if you are going to make changes to the **public** interface that are not backwards-compatible, make sure it is **absolutely** necessary.

### Changelog
From v2.0.0 on, we are going to take note of changes in a proper `CHANGELOG.md`.
For any contribution, please add a corresponding changelog entry.  
Bump the patch version for bug fixes and the minor version for feature additions.  
Don't **ever** bump the major version on your behaf - It should be done only by the owners of the project.

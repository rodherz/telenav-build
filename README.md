
KivaKit Master Build
====================

This project combines KivaKit and the most important dependent projects into a single parent repository 
using [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules). This enables a single,
consistent build of the following projects:

  * KivaKit
  * MesaKit
  * Lexakai

The Maven `pom.xml` in this project is a _bill of materials only_ which is used to build all child projects.
Since they are all built in the same [Maven reactor](https://books.sonatype.com/mvnref-book/reference/_using_advanced_reactor_options.html),
breaking changes can be detected immediately.

## Requirements

The following products are required to build KivaKit:

 - Java
 - Maven
 - Git
 - Git Flow (brew install git-flow)
 - Github CLI (brew install gh)

## Setup

Clone this repository, specifying the branch you want to work with:

```
git clone --branch [branch-name] https://github.com/Telenav/kivakit-build.git
```

Where [branch-name] is one of:

 - master (latest stable code)
 - develop (development code)

Next, execute:

```
cd kivakit-build
./setup.sh
```

This will cause all projects for the branch to be checked out and built.

## Development Builds

Once the initial setup has been created, to build on a development machine, execute:

```
cd kivakit-build
source ./source-me
mvn clean install
```



Telenav Build
=============

This project combines all Telenav Open Source projects into a single parent repository 
using [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules). This enables a single,
consistent build of any combination of the following projects:

 * Cactus Build - Maven plugins and build libraries
 * KivaKit - General purpose development kit
 * MesaKit - Development kit for map data processing
 * Lexakai - Automated UML and markdown documentation tool

Note: The Maven `pom.xml` in this project is _bill of materials only_. It is used to build all child projects.
Since they are all built in the same [Maven reactor](https://books.sonatype.com/mvnref-book/reference/_using_advanced_reactor_options.html),
breaking changes can be detected immediately.

## Requirements

The following products are required to build Telenav Open Source projects:

 - Java 17.0.2+
 - Maven 3.8.5+
 - Git 2.30.1+
 - Git Flow 1.12.3 (AVH Edition)

> NOTE: The git flow AVH edition is **required**. To install the AVH edition on macOS:
> 
> brew install git-flow-avh

## Setup

Clone this repository, specifying the branch you want to work with:

```
git clone --branch [branch-name] https://github.com/Telenav/telenav-build.git
```

Where [branch-name] is one of:

 - master (latest release)
 - develop (development code)

Next, execute:

```
cd telenav-build
./setup.sh [branch-name]
```

Where [branch-name] is one of:

 - master (latest release)
 - develop (development code)
 - feature/* (feature branch)
 - hotfix/* (fix branch)

This will cause all projects for the branch to be checked out and built.

## Development Builds

Once the initial setup has been completed, future builds can be executed like this:

```
source ./source-me
mvn clean install
```

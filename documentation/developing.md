<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

# Developing &nbsp; &nbsp;  <img src="https://telenav.github.io/telenav-assets/images/icons/bluebook-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/bluebook-32-2x.png 2x"/>

If you are helping to develop Telenav Open Source projects this page will help you get going. 

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## Setup

1. Follow the [Initial Setup Instructions](initial-setup-instructions.md).


2. Download and install [IntelliJ](https://www.jetbrains.com/idea/download/) or [Netbeans](https://netbeans.apache.org/download/index.html)


3. In IntelliJ, use `File` / `Manage IDE Settings` / `Import Settings` to import `setup/intellij/telenav-all-settings.zip`

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

## Our Development Practices

Once you're ready to go, these articles can help you to understand our development practices:

- [Telenav Open Source Process](telenav-open-source-process.md)  
- [Versioning](versioning.md)  
- [Releasing](releasing.md)  
- [Naming Conventions](naming-conventions.md)  
- [Java 17+ Migration Notes](java-17-migration-notes.md)

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

## Convenient Scripts for Developers

The `bin` folder of `telenav-build` contains a set of bash scripts, all prefixed with `telenav-`.
After following the [Initial Setup Instructions](documentation/initial-setup-instructions.md), 
the `bin` folder will be on your PATH. The scripts described here translate a simple keyword
language into arguments to Git and Maven. Since all scripts have an equivalent Git or Maven syntax, 
they are *not required*, merely convenient. Note that the order of parameters to `telenav-*.sh` 
scripts does not matter.

> **HINT**: To see what scripts are available, type `telenav-` in a bash shell and hit `TAB`. 

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

## Project Scopes

The `telenav-build` workspace can contain any set of Telenav Open Source projects.
To allow `telenav-build.sh` to build different subsets of these projects, an optional
project `build-scope` specifier is accepted, which must be one of:
 
 - `all` `[default]` - All repositories in the TELENAV_WORKSPACE
 - `this` - The project in the current folder
 - `[family-name]` - A family of repositories, such as `kivakit`, `mesakit`, `cactus-build` or `lexakai`

## The Build Script &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/command-line-24.png" srcset="https://telenav.github.io/telenav-assets/images/icons/command-line-24-2x.png 2x"/>

The `telenav-build.sh` script helps to compose Maven commands. It takes an optional `build-scope`,
zero or more `build-modifiers`, and a `build-type`:

*telenav-build.sh* `[build-scope]`**?** `[build-modifier]`* `[build-type]`

> See below for descriptions of build scopes, modifiers, and types.

## Examples &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/books-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/books-32-2x.png 2x"/>


For example, `telenav-build.sh kivakit release` builds a release of the KivaKit project and uploads
it to OSSRH (staging for Maven Central). Some common usages:

| Example Command                    | Purpose                                                                                            |
|------------------------------------|----------------------------------------------------------------------------------------------------|
| *telenav-build.sh*                 | Build all projects and run tests                                                                   |
| *telenav-build.sh release*         | Build a release and upload it to OSSRH                                                             |
 | *telenav-build.sh release-local*   | Build a release but don't upload it                                                                |
 | *telenav-build.sh compile*         | Make sure the code can compile only                                                                |
 | *telenav-build.sh clean-all*       | Build all projects after removing cached and temporary files, and all Telenav repository artifacts |
| *telenav-build.sh clean-sparkling* | Build completely from scratch after removing the entire local Maven repository                     |
| *telenav-build.sh javadoc*         | Build javadoc documentation                                                                        |
| *telenav-build.sh javadoc lexakai* | Build javadoc and lexakai documentation                                                            |
| *telenav-build.sh single-threaded* | Build with only one thread (12 is the default)                                                     |


## Different Kinds of Builds &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/set-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/set-32-2x.png 2x"/>

The `build-type` parameter to `telenav-build` specifies the goal of the build.

| Build Types     | Purpose                                                              |
|-----------------|----------------------------------------------------------------------|
| *[default]*     | Builds projects, creates shaded jars and runs tests                  |
| *compile*       | Compiles projects and creates shaded jars                            |
| *javadoc*       | Builds javadoc for all projects                                      |
| *release-local* | Builds a release locally                                             |
| *release*       | Builds a release and uploads it to OSSRH (staging for Maven Central) |

## Build Modifiers &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/stars-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/stars-32-2x.png 2x"/>


The `build-modifier` parameter(s) adds or removes switches from those specified by `build-type`.
They effectively *modify* the kind of build.

| Build Modifier   | Purpose                                                                      |
|------------------|------------------------------------------------------------------------------|
| clean            | Prompts to remove cached and temporary files                                 |
| clean-all        | Prompt to remove cached and temporary files and kivakit artifacts from ~/.m2 |
| clean-sparkling  | Prompts to remove entire .m2 repository and all cached and temporary files   |
| debug            | Turn on Maven debug output                                                   |
| debug-tests      | Turn on Surefire debugging                                                   |
| dry-run          | Show what Maven command would be run, without running it                     |
| no-javadoc       | Turns off javadoc for a build type that normally includes it                 |
| no-tests         | Turns off testing for a build type that normally includes it                 |
| quick-tests      | Only run tests annotated with @QuickTest                                     |                                    |
| verbose          | Build will normal output (default is quiet)                                  |
| single-threaded  | Build with only one thread                                                   |
| tests            | Run tests for a build type that normally excludes testing                    |

## Source Control Scripts <img src="https://telenav.github.io/telenav-assets/images/icons/branch-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/branch-32-2x.png 2x"/>

Telenav Open Source projects are published on [Github](https://www.github.com/) and use Git for source control. 
All Telenav Open Source repositories adhere to the standard [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) branching model.
This model specifies the following branch naming convention:

| Git Flow Branch | Purpose               |
|-----------------|-----------------------|
| `master`        | Latest stable release |
| `develop`       | Development build     |
| `feature/*`     | Feature branches      |
| `hotfix/*`      | Hot fix branches      |

After following the [Initial Setup Instructions](initial-setup-instructions.md), the scripts below will be available.


| Script                                                                           | Purpose                                                   |
|----------------------------------------------------------------------------------|-----------------------------------------------------------|
| *telenav-git-checkout.sh* `scope`**?** `branch-name`                             | Checks out the given branch for the scoped repositories   |
| *telenav-git-commit.sh* `scope`**?** `message`                                   | Commits to the scoped repositories with the given message |
| *telenav-git-hard-reset.sh*                                                      | Resets the current repository, losing all changes         |
| *telenav-git-is-dirty.sh* `scope`**?**                                           | Shows which scoped repositories are dirty                 |
| *telenav-git-pull.sh* `scope`**?**                                               | Pulls from all scoped repositories                        |
| *telenav-git-pull-request.sh* `scope`**?** `authentication-token` `title` `body` | Pulls from all scoped repositories                        |
| *telenav-git-status.sh*                                                          | Shows the status of all repositories in the workspace     |
| *telenav-git-start-[branch-type].sh* `branch-name`                               | Starts a git flow branch of the given type                |
| *telenav-git-finish-[branch-type].sh* `branch-name`                              | Ends a git flow branch of the given type                  |

Where `scope` is one of:
 
 - `all` - All repositories in the TELENAV_WORKSPACE
 - `this` - The project in the current folder
 - `[family-name]` - A family of repositories, such as `kivakit`, `mesakit` or `lexakai`

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

<sub>Copyright &#169; 2011-2021 [Telenav](https://telenav.com), Inc. Distributed under [Apache License, Version 2.0](../LICENSE)</sub>  
<sub>This documentation was generated by [Lexakai](https://www.lexakai.org). UML diagrams courtesy of [PlantUML](https://plantuml.com).</sub>

<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

# Developing &nbsp; &nbsp;  <img src="https://telenav.github.io/telenav-assets/images/icons/bluebook-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/bluebook-32-2x.png 2x"/>

If you are helping to develop Telenav Open Source projects this page will help you get going. 

### Index

 - [**Setup**](#setup)
 - [**Development Practices**](#development-practices)
 - [**Convenient Scripts for Developers**](#scripts-for-developers)
 - [**Feature Development Workflow**](#workflow-for-developing-a-feature)
 - [**Workspace Information**](#workspace-information)
 - [**Building**](#building)
 - [**Build Examples**](#build-examples)
 - [**Build Scopes**](#build-scopes)
 - [**Build Types**](#build-types)
 - [**Build Modifiers**](#build-modifiers)
 - [**Source Control**](#source-control)
 - [**Git Flow**](#git-flow)
 - [**Git Operations**](#git-operations)
 - [**Adding a Submodule**](#adding-a-submodule)

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

<a name = "setup"></a>
## Setup

1. Follow the [Initial Setup Instructions](initial-setup-instructions.md).

2. Download and install [IntelliJ](https://www.jetbrains.com/idea/download/) or [Netbeans](https://netbeans.apache.org/download/index.html)

3. In IntelliJ, use `File` / `Manage IDE Settings` / `Import Settings` to import `setup/intellij/telenav-all-settings.zip`

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

<a name = "development-practices"></a>
## Our Development Practices

Once you're ready to go, these articles can help you to understand our development practices:

- [Telenav Open Source Process](telenav-open-source-process.md)  
- [Versioning](versioning.md)  
- [Releasing](releasing.md)  
- [Naming Conventions](naming-conventions.md)  
- [Java 17+ Migration Notes](java-migration-notes.md)

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

<a name = "scripts-for-developers"></a>
## Convenient Scripts for Developers

The `telenav-build/bin` folder contains a set of bash scripts, all prefixed with `telenav-`.
After following the [Initial Setup Instructions](documentation/initial-setup-instructions.md), 
the `bin` folder will be on your PATH. The scripts described here translate their arguments
into arguments for Git and Maven. Since all scripts have an equivalent Git or Maven syntax, 
they are *not required*, merely convenient.

> **HINT**: To see what scripts are available, type `telenav-` in a bash shell and hit `TAB`. 

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

<a name = "feature-development"></a>
## Workflow for Developing a Feature

1. `telenav-develop`--switch all projects to the `develop` branch
2. `telenav-start-feature hover-mode-#87`--create and switch all projects in the workspace to the feature/hover-mode#87branch
3. [coding]
4. `telenav-push`--push all relevant branches to Github
5. `telenav-pull-request`--create a pull request for the branch
6. [code review]
7. `telenav-merge-pull-request`--merge all pull requests at once into the `develop` branch and delete the feature branch
8. `telenav-develop`--switch all projects back to the `develop` branch

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

<a name = "workspace-information"></a>
## Workspace Information

To get the versions of tools, and repository families in the Telenav workspace, run `telenav-version`:

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Versions ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┋
    ┋  Repositories:
    ┋
    ┋          KivaKit: 1.6.0
    ┋          MesaKit: 0.9.14
    ┋
    ┋  Tools:
    ┋
    ┋             Java: 17.0.3
    ┋            Maven: 3.8.5
    ┋              Git: 2.36.1
    ┋
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

To get information about the projects in the Telenav workspace, run `telenav-workspace`:

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Telenav Workspace ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┋
    ┋        TELENAV_WORKSPACE: /Users/jonathan/Workspaces/kivakit-1.6/feature
    ┋
    ┋             KIVAKIT_HOME: /Users/jonathan/Workspaces/kivakit-1.6/feature/kivakit
    ┋          KIVAKIT_VERSION: 1.6.0
    ┋       KIVAKIT_CACHE_HOME: /Users/jonathan/.kivakit/1.6.0
    ┋      KIVAKIT_ASSETS_HOME: /Users/jonathan/Workspaces/kivakit-1.6/feature/kivakit-assets
    ┋     KIVAKIT_JAVA_OPTIONS: -Xmx12g
    ┋
    ┋             MESAKIT_HOME: /Users/jonathan/Workspaces/kivakit-1.6/feature/mesakit
    ┋          MESAKIT_VERSION: 0.9.14
    ┋       MESAKIT_CACHE_HOME: /Users/jonathan/.kivakit/0.9.14
    ┋      MESAKIT_ASSETS_HOME: /Users/jonathan/Workspaces/kivakit-1.6/feature/mesakit-assets
    ┋     MESAKIT_JAVA_OPTIONS: -Xmx12g
    ┋
    ┋                JAVA_HOME: /Users/jonathan/Developer/amazon-corretto-17.jdk/Contents/Home
    ┋
    ┋                  M2_HOME: /Users/jonathan/Developer/apache-maven-3.8.5
    ┋
    ┋                     PATH: /Users/jonathan/Developer/amazon-corretto-17.jdk/Contents/Home/bin
    ┋                           /Users/jonathan/Developer/apache-maven-3.8.5/bin
    ┋                           /usr/local/bin
    ┋                           /usr/bin
    ┋                           /bin
    ┋                           /usr/sbin
    ┋                           /sbin
    ┋                           /Library/TeX/texbin
    ┋                           /Users/jonathan/Workspaces/kivakit-1.6/feature/bin
    ┋
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

<a name = "building"></a>
## Building &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/command-line-24.png" srcset="https://telenav.github.io/telenav-assets/images/icons/command-line-24-2x.png 2x"/> 
The `telenav-build` script helps to compose Maven commands. It takes an optional `build-scope`,
zero or more `build-modifiers`, and a `build-type`:

`telenav-build` `[build-scope]`**?** `[build-modifier]`**&ast;** `[build-type]`

<a name = "build-examples"></a>
### Build Examples &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/books-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/books-32-2x.png 2x"/>

For example, `telenav-build kivakit release` builds a release of the KivaKit project family and uploads
it to OSSRH (Maven Central staging). Some more examples:

| Example Command                       | Purpose                                                                                            |
|---------------------------------------|----------------------------------------------------------------------------------------------------|
| `telenav-build`                       | Build all projects and run tests                                                                   |
| `telenav-build help`                  | Show script help                                                                                   |
| `telenav-build kivakit release`       | Build a release for the kivakit project family and upload it to OSSRH (Maven Central staging)      |
 | `telenav-build mesakit release-local` | Build a release for the mesakit project family but don't upload it                                 |
 | `telenav-build compile`               | Compile the code in all repositories                                                               |
 | `telenav-build clean`                 | Build all projects after removing cached and temporary files, and all Telenav repository artifacts |
| `telenav-build clean-sparkling`       | Build completely from scratch after removing the entire local Maven repository                     |
| `telenav-build javadoc`               | Build javadoc documentation for all project families                                               |
| `telenav-build javadoc lexakai`       | Build javadoc and lexakai documentation for all project families                                   |
| `telenav-build single-threaded`       | Build all projects with only one thread (12 is the default)                                        |

<a name = "build-scopes"></a>
### Build Scopes

The `telenav-build` workspace can contain any set of Telenav Open Source projects.
To allow `telenav-build` to build different subsets of these projects, an optional
project `build-scope` specifier is accepted, which must be one of:

| Build Scope                           | Purpose                                                                                             | 
|---------------------------------------|-----------------------------------------------------------------------------------------------------|
| `all-project-families`  **[default]** | All repositories belonging to any project family                                                    |
| `[project-family]`                    | All repositories belonging to a project family, such as `kivakit`, `mesakit`, `cactus` or `lexakai` |

<a name = "build-types"></a>
### Build Types &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/set-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/set-32-2x.png 2x"/>

The `build-type` parameter to `telenav-build` specifies the goal of the build.

| Build Type              | Purpose                                                              |
|-------------------------|----------------------------------------------------------------------|
| `[default]`             | Builds projects, creates shaded jars and runs tests                  |
| `compile`               | Compiles projects and creates shaded jars                            |
| `help`                  | Shows help                                                           |
| `javadoc`               | Builds javadoc                                                       |
| `lexakai-documentation` | Builds lexakai documentation                                         |
| `release-local`         | Builds a release                                                     |
| `release`               | Builds a release and uploads it to OSSRH (staging for Maven Central) |

<a name = "build-modifiers"></a>
### Build Modifiers &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/stars-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/stars-32-2x.png 2x"/>

The `build-modifier` parameter(s) adds or removes switches from those specified by `build-type`.
They effectively *modify* the kind of build.

| Build Modifier          | Purpose                                                                    |
|-------------------------|----------------------------------------------------------------------------|
| `attach-jars`           | Attaches javadoc and source jars                                           |
| `clean`                 | Prompts to remove cached and temporary files                               |
| `clean-sparkling`       | Prompts to remove entire .m2 repository and all cached and temporary files |
| `debug`                 | Turn on Maven debug output                                                 |
| `debug-tests`           | Turn on Surefire debugging                                                 |
| `dry-run`               | Show what Maven command would be run, without running it                   |
| `lexakai-documentation` | Build lexakai documentation                                                |
| `multi-threaded`        | Build with multiple threads                                                |
| `no-javadoc`            | Turns off javadoc for a build type that normally includes it               |
| `no-tests`              | Turns off testing for a build type that normally includes it               |
| `quick-tests`           | Only run tests annotated with @QuickTest                                   |
| `quiet`                 | Don't show surefire summaries or KivaKit information                       |
| `sign-artifacts`        | Creates digital signatures for jar artifacts                               |
| `single-threaded`       | Build with only one thread                                                 |
| `tests`                 | Run tests for a build type that normally excludes testing                  |
| `verbose`               | Build will normal output (default is quiet)                                |

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

<a name = "source-control"></a>
## Source Control <img src="https://telenav.github.io/telenav-assets/images/icons/branch-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/branch-32-2x.png 2x"/>

Telenav Open Source projects are published on [Github](https://www.github.com/) and use Git for source control. 

&nbsp; <a name = "git-flow"></a>
### The Git Flow Branching Model

Although Telenav Open Source projects do not use git flow, they adhere to the [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) branching model.
This model specifies the following branch naming convention:

| Git Flow Branch     | Purpose               |
|---------------------|-----------------------|
| `release/current`   | Latest stable release |
| `release/[version]` | Release               |
| `develop`           | Development build     |
| `bugfix/*`          | Bug fix branches      |
| `feature/*`         | Feature branches      |
| `hotfix/*`          | Hot fix branches      |

<a name = "git-operations"></a>
### Git Operations

After following the [Initial Setup Instructions](initial-setup-instructions.md), the scripts below will be available.
These scripts work on all projects in the workspace, which is the primary use case for developers. For more 
granular work using scopes, see [Cactus](https://github.com/Telenav/cactus).


| Script                                      | Purpose                                                                          |
|---------------------------------------------|----------------------------------------------------------------------------------|
| `telenav-checkout` `branch-name`            | Checks out the given branch of all repositories in the workspace                 |
| `telenav-commit` `message`                  | Commits all workspace changes with the given message                             |
| `telenav-reset`                             | Resets the workspace, losing all changes                                         |
| `telenav-is-dirty`                          | Shows which repositories in the workspace are dirty                              |
| `telenav-pull`                              | Pulls from all repositories in the workspace                                     |
| `telenav-pull-request` `title` `body`       | Creates a pull request for all repositories in the workspace                     |
| `telenav-push`                              | Pushes all changes in the workspace                                              |
| `telenav-status`                            | Shows the status of all repositories in the workspace                            |
| `telenav-start-[branch-type]` `branch-name` | Starts a branch of the given git-flow type for all repositories in the workspace |

Here, `branch-type` must be one of:

 - `bugfix`
 - `feature`
 - `hotfix`

<a name = "adding-a-submodule"></a>
### Adding a Submodule

To add a submodule to a workspace:

```
git submodule add -b [branch-name] [repository-name]  
git submodule init  
git submodule update
```

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

<sub>Copyright &#169; 2011-2021 [Telenav](https://telenav.com), Inc. Distributed under [Apache License, Version 2.0](../LICENSE)</sub>  
<sub>This documentation was generated by [Lexakai](https://www.lexakai.org). UML diagrams courtesy of [PlantUML](https://plantuml.com).</sub>

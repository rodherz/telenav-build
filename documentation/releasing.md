<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

# Releasing Telenav Open Source Projects  &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/rocket-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/rocket-32-2x.png 2x"/>

## Step-by-Step Instructions &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/footprints-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/footprints-32-2x.png 2x"/>

This section describes step-by-step how to release a new version of any Telenav Open Source project.

In the text below *\[project-version\]* refers to a [semantic versioning](https://semver.org) identifier, such as `2.1.7`, `4.0.1-SNAPSHOT` or `1.4.0-beta`.

Telenav Open Source projects adhere to the [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) branching model.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## Project Families

The `telenav-build` workspace can contain any set of Telenav Open Source projects.
The release scripts take a `project-family` to choose which project to release:
 
 - `kivakit`
 - `mesakit`
 - `cactus-build`
 - `lexakai`

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 1. Preparing the Release <img src="https://telenav.github.io/telenav-assets/images/icons/branch-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/branch-32-2x.png 2x"/>

### 1.1 Creating the Release Branch

To create a release branch and update version numbers in the project:

    telenav-release.sh [project-family] [project-version]

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.2 Updating the Change Log

Examine the git history log of all four *kivakit** repositories, and update the *change-log.md* file with any important information about the release.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.3 Updating the Project Code Flowers

To update code flowers for the release:

1. On the command line, execute:

        mkdir -p $KIVAKIT_WORKSPACE/kivakit-assets/docs/$KIVAKIT_VERSION

2. Copy the *codeflowers* folder from a previous build into this folder


3. Inside the *codeflowers* folder, execute:

        ./kivakit-build-codeflowers.sh

4. If there have been any projects added or removed since the last release, open *site/index.html* in an editor and insert the &lt;option&gt; HTML code that was output by the kivakit-build-codeflowers.sh.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.4 Building the Release Branch

To build the release branch on the local machine:

    telenav-build.sh [project-family] release-local

This will build all project artifacts from scratch (answer 'y' to the prompt to remove all artifacts), including Javadoc and Lexakai documentation.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.5 Committing Final Changes 

Commit any final changes to the release branch:

    telenav-release-finish.sh [project-family] [project-version]

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 2. Publishing the Release &nbsp;  <img src="https://telenav.github.io/telenav-assets/images/icons/books-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/books-32-2x.png 2x"/>

### 2.0 Merge the Release Branch to Master

Merge the release branch into the master branch:

    telenav-finish-release.sh [project-family]

### 2.1 Push the Release to OSSRH (Maven Central Staging)

To push the release to OSSRH, run:

    telenav-build.sh [project-family] release

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 2.2 Publish from OSSRH to Maven Central

The sign into [OSSRH](http://s01.oss.sonatype.org) and push the build to Maven Central.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

<sub>Copyright &#169; 2011-2021 [Telenav](https://telenav.com), Inc. Distributed under [Apache License, Version 2.0](../LICENSE)</sub>  
<sub>This documentation was generated by [Lexakai](https://www.lexakai.org). UML diagrams courtesy of [PlantUML](https://plantuml.com).</sub>

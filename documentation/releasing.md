<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

# Releasing Telenav Open Source Projects  &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/rocket-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/rocket-32-2x.png 2x"/>

## Step-by-Step Instructions &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/footprints-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/footprints-32-2x.png 2x"/>

This section describes, step-by-step, how to release a new version of any Telenav Open Source project.

In the text below `project-version` refers to a [semantic versioning](https://semver.org) identifier, such as `2.1.7`, `4.0.1-SNAPSHOT` or `1.4.0-beta`.
Telenav Open Source projects adhere to the [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) branching model.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## Release Cheat Sheet &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/stars-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/stars-32-2x.png 2x"/>

The sections below give a full description of the release process. After reading about the process,
this cheat sheet gives a quick summary for future reference:

> 1. Switch to `develop` with `telenav-git-checkout.sh [project-family] develop`
> 2. Update `change-log.md`
> 3. Build the release with `telenav-release.sh [project-family] [release-version]`
> 4. Check the release carefully
> 5. Push the release to OSSRH with `telenav-release-finish.sh [project-family] [release-version]`
> 6. Sign into [OSSRH](https://s01.oss.sonatype.org) and push the release to Maven Central

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 1. Creating the Release <img src="https://telenav.github.io/telenav-assets/images/icons/branch-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/branch-32-2x.png 2x"/>

To prepare the release for publication, the following steps must be followed.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.0 Prerequisites

1. Complete all steps of [developer setup](developing.md)
2. Releasing software to Maven Central requires PGP keys to be installed. Contact the project's administrator(s) for access to them.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.1 Preparing the Develop Branch

To prepare the `develop` branch for the release:

1. Check out the `develop` branch with `telenav-git-checkout.sh [project-family] develop`
2. Update `change-log.md` for the project family

> A `project-family` selects group of related projects:
>
> - `cactus`
> - `kivakit`
> - `mesakit`
> - `lexakai`

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.2 Creating and Building the Release Branch

Execute this command to create the release:

    telenav-release.sh [project-family] [release-version]
    
For example:

    telenav-release.sh kivakit 1.6.0

The `telenav-release.sh` script:

1. Creates a release branch called `release/[release-version]`
2. Updates version numbers in `pom.xml` files and `.md` files
3. Builds the release into the local repository

When the build is successful, and it looks good, the build is ready to be published

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 2. Publishing the Release &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/books-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/books-32-2x.png 2x"/>

### 2.0 Pushing the Release to OSSRH (Maven Central Staging)

Execute this command to publish the release:

    telenav-release-finish.sh [project-family] [release-version]

The `telenav-release.sh` script does the following:    

1. Builds the release
2. Uploads it to OSSRH (Maven Central Staging)
3. Finishes the release branch, merging the result into the `release/current` branch

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 2.1 Pushing the Release from OSSRH to Maven Central

The sign into Sonatype [OSSRH](https://s01.oss.sonatype.org) (using credentials provided by a project administrator), and push the build to Maven Central:

1. Locate the staged build (created above) by clicking the *Staging Repositories* link
2. Select the repository to publish and click the *Close* button (YES, this is counterintuitive!)
3. Check the activities tab for the selected repository. If all went well, the *Release* button will be available and can be pushed to publish the build to *Maven Central*. If the release button remains disabled, the specific requirement that failed will be displayed in the list of verification activities, so it can be addressed before trying again.


<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 3. Preparing to Develop the Next Version &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/right-arrow-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/right-arrow-32-2x.png 2x"/>

To prepare for development of the next version of the project:

1. Check out the `develop` branch with `telenav-git-checkout.sh [project-family]`
2. Update the version of the project family with `telenav-update-version.sh [project-family] [next-version] develop`
3. Commit and push the changes

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

<sub>Copyright &#169; 2011-2021 [Telenav](https://telenav.com), Inc. Distributed under [Apache License, Version 2.0](../LICENSE)</sub>  
<sub>This documentation was generated by [Lexakai](https://www.lexakai.org). UML diagrams courtesy of [PlantUML](https://plantuml.com).</sub>

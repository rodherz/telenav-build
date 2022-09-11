<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

# Releasing Telenav Open Source Projects

## Step-by-Step Instructions &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/footprints-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/footprints-32-2x.png 2x"/>

This section describes, step-by-step, how to release a new version of any Telenav Open Source project.

In the text below `project-version` refers to a [semantic versioning](https://semver.org) identifier, such as `2.1.7`, `4.0.1-SNAPSHOT` or `1.4.0-beta`.

Although Telenav Open Source projects do not use git flow, they adhere to the [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) branching model.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 0. Prerequisites  &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/box-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/box-32-2x.png 2x"/>


1. Complete all steps of [developer setup](developing.md)
2. Releasing software to Maven Central requires PGP keys to be installed. Contact the project's administrator(s) for access to them.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 1. Releasing &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/branch-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/branch-32-2x.png 2x"/>

To create a release, we must follow the steps below.
 
<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.1 Starting the Release

To begin the release process:
 
 - Ensure that we're on the `develop` branch
 - The `change-log.md` for each project should be updated
 - All changes should be checked in

From the root of our `telenav-build` workspace we execute:

```
./release
```

To create a release and publish it to Maven Central, we pass `publish` as an argument to `release`:

```
./release publish
``` 

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.2 Selecting Project Families to Release

Next, we will be asked by the release script to select the project families to release:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Cactus 1.5.18
┋
┋ What project families do you want to release [kivakit,lexakai,mesakit]?
```

To release all families, simply press return. To release a specific family or families,
we can provide a list of one or more families separated by commas, like `kivakit,mesakit`.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.3 Specify Release Versions

For each project family, we are then asked what version to release:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Cactus 1.5.18
┋
┋ What project families do you want to release [kivakit,lexakai,mesakit]? kivakit,mesakit
┋
┋    - kivakit release should be the next (major, minor, dot) version or the current version [current]?
┋    - mesakit release should be the next (major, minor, dot) version or the current version [current]?
```

The default version to release is `current`. This will create a release for the current 
(snapshot) version in the workspace. When the release is complete, the workspace will be 
updated to the next snapshot version. For example, if the workspace is at 2.5.9-SNAPSHOT, 
the released version will be 2.5.9, and when the release completes the `develop` branch 
will be 2.5.10-SNAPSHOT.

If `major` or `minor` is selected, the next major or minor version number will be released.
For example, if the workspace is at 2.5.9-SNAPSHOT and 'minor' is selected, the version
2.6.0 will be released, and when the release is complete, the `develop` branch will be
2.6.1-SNAPSHOT.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.4 Release Options

The following options can be passed to the `release` script:

| Option      | Description                                                      |
|-------------|------------------------------------------------------------------|
| help        | Show command line help                                           |
| publish     | Publish the release to Maven Central                             |
| quiet       | Reduce output to the minimum (build errors will always be shown) |
| fast        | Build with multiple threads (not recommended when publishing     |
| skip-review | Skip documentation review                                        |

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.5 Creating the Release.

At this point, the release will be prepared automatically. Nothing further is required
except review of the generated documentation (see below). The following steps are taken
to prepare the release:

 - The code on Github corresponding to the `develop` branch we are on will be cloned into a temporary workspace folder in `/tmp`
 - The release build will use `/tmp/maven-repository` to ensure that the release works with an empty Maven repository
 - All project caches will be removed to ensure that they can be correctly reconstructed

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### 1.6 Documentation Review

If the `skip-review` option is not passed to `release`, the release process will pause
to allow review of the documentation on Github:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Review ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┋
┋ Release is ready for you to review now:
┋
┋    1. Check the documentation on Github, including links and diagrams
┋    2. Check that version numbers and branch names were updated correctly
┋
┋ The release is in /tmp/[workspace]
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

 When ready to publish to Nexus / OSSRH staging for Maven Central, type 'publish': 
```

After reviewing the documentation that has been pushed to Github, we type `publish` to 
proceed with publishing the release.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## 2. Publishing to Maven Central   &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/rocket-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/rocket-32-2x.png 2x"/>

The release should now be ready for Maven Central. We sign into Sonatype [OSSRH](https://s01.oss.sonatype.org) (using credentials provided by a project administrator), and push the release:

1. Locate the staged build (created above) by clicking the *Staging Repositories* link
2. Check the activities tab for the selected repository. If all went well, the *Release* 
   button will be available and can be pushed to publish the build to *Maven Central*. 
   If the release button remains disabled, the specific requirement that failed will be
   displayed in the list of verification activities, so it can be addressed before trying again.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

<sub>Copyright &#169; 2011-2021 [Telenav](https://telenav.com), Inc. Distributed under [Apache License, Version 2.0](../LICENSE)</sub>  
<sub>This documentation was generated by [Lexakai](https://www.lexakai.org). UML diagrams courtesy of [PlantUML](https://plantuml.com).</sub>

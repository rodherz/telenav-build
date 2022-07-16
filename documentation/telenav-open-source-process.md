<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

# Telenav Open Source Process &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/world-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/world-32-2x.png 2x"/>

## Overview &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/map-24.png" srcset="https://telenav.github.io/telenav-assets/images/icons/map-24-2x.png 2x"/>

Telenav Open Source projects are distributed under [Apache License, Version 2.0](../kivakit/LICENSE)</sub>. This guide explains how projects are organized and maintained.

Please keep the following in mind as you work on any Telenav Open Source project:

1. *Nobody owes you anything*. Most people who work on open source projects do so out of pure passion for software development and to solve a problem they think is worth solving. This might not include the particular issue you are focused on. Being well-informed, friendly and patient can help you to make your case. Be willing to help out if you can.

2. If you want a bug fix or improvement badly, consider doing it yourself. If the change might be significant, you may also want to contact project administrators, to ensure you're working on something that is desired by the community in a way that will be likely to be accepted.

3. *Always show respect and give thanks for work that other people do*. Take that attitude with you when evangelizing your favorite open source project.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## Setup &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/box-24.png" srcset="https://telenav.github.io/telenav-assets/images/icons/box-24-2x.png 2x"/>

This section describes the OSS setup requirements for end-users, developers of Telenav Open Source projects, and administrators.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### End-Users 

Telenav Open Source artifacts are published to *Maven Central* and no special setup is required to use these artifacts.
 
### Telenav Open Source Developers

Contributions of bug fixes and improvements from developers in the form of pull requests (PRs) don't require any special setup, other than the [*setup for developing*](developing.md).

### Administrators

Project administrators require some additional setup to publish snapshots and releases:

1. Administrative access to *GitHub* repositories is required to commit changes, run build workflows and perform other necessary tasks.

2. A username and password to the
   *Sonatype [Open Source Software Repository Hosting](https://s01.oss.sonatype.org/)* (OSSRH)
   service, are required to push releases to *Maven Central*.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## Publishing Requirements &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/books-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/books-32-2x.png 2x"/>

OSSRH and *Maven Central* have rigorous requirements for publishing artifacts. A new organization must claim a namespace (group id) on *Maven Central*, and artifacts that are published there must adhere to the requirements described below under in section entitled *Publishing a New Project*.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-128-2x.png 2x"/>

### Setup for an OSS Namespace

The following steps were executed to set up the *com.telenav* namespace (group id) to allow publishing of artifacts 
from *Telenav*.

> *These steps have already been performed and do not need to be followed again*
> but they are noted here to serve as a reference in the future for how things were 
> done, and to guide any future projects that might be published under a different
> namespace.

1. Create a [*Sonatype JIRA*](https://issues.sonatype.org/) account

2. Create a *New Project* ticket to register a namespace (aka "group id") for the project. See the [*OSSRH Guide*](https://central.sonatype.org/publish/publish-guide/) for details.

3. Respond to any requests from community volunteers, including domain ownership verification processes. For details on how this exchange might proceed take a look at the JIRA ticket [Request com.telenav namespace for Telenav, Inc.](https://issues.sonatype.org/browse/OSSRH-68055)
   that was used to set up the *Telenav* namespace.

   [...]

4. Once the first artifact is published according to the steps described in the following section, notify *Sonatype* OSSRH using the *JIRA New Project* ticket opened above, and they will turn on replication to *Maven Central*.

5. GPG signing keys must be created and used to sign builds. These keys should be kept safe and added to *GitHub* as organization-wide "secrets" for use in *GitHub* integration builds, along with an OSSRH username and password valid for publishing builds:

![](images/secret-keys.png)

*Again, all of these steps have already been performed and should not be needed again.*

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## Publishing a Project &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/truck-40.png" srcset="https://telenav.github.io/telenav-assets/images/icons/truck-40-2x.png 2x"/>

To publish artifacts to *Maven Central* in the *Telenav* namespace established above, the project build must conform to the specifications enforced by the *Sonatype Nexus* publishing tools:

1. Source archives must be attached
2. Javadoc archives must be attached
3. Artifacts must be signed with PGP

The [*OSSRH Guide*](https://central.sonatype.org/publish/publish-guide/) provides full details, as well as a series of videos that show just what to do (featuring *very loud* mandolin music, and thorough, patient narration in an excellent german accent).

For information about preparing releases, see [releasing](releasing.md).

Once a project is ready to publish to Maven Central, the *Sonatype Nexus Repository Manager* provides an easy way to do this:

1. Sign in to the *Sonatype OSSRH [Nexus Repository Manager](https://s01.oss.sonatype.org/)*

2. Locate the staged build (created above) by clicking the *Staging Repositories* link

3. Select the repository to publish and click the *Close* button (YES, this is counterintuitive!)

4. Check the activities tab for the selected repository, and if all went well, the *Release* button will be available and can be pushed to publish the build to *Maven Central*. If the release button remains disabled, the specific requirement that failed will be displayed in the list of verification activities, so it can be addressed before trying again.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

## GitHub Continuous Integration (CI) Builds &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/box-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/gears-32-2x.png 2x"/>

When code is checked into a Telenav Open Source project, [*GitHub actions*](https://github.com/Telenav/kivakit/actions) will automatically perform a build. The status of the build will appear when it completes.
To ensure that `develop` branch builds are stable, it is required that feature branches build cleanly before they can be merged.

<img src="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512.png" srcset="https://telenav.github.io/telenav-assets/images/separators/horizontal-line-512-2x.png 2x"/>

<sub>Copyright &#169; 2011-2021 [Telenav](https://telenav.com), Inc. Distributed under [Apache License, Version 2.0](../LICENSE)</sub>  
<sub>This documentation was generated by [Lexakai](https://www.lexakai.org). UML diagrams courtesy of [PlantUML](https://plantuml.com).</sub>

<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

Telenav Build
=============

This project combines all Telenav Open Source projects into a single parent repository 
using [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).  
This enables a single, consistent build of any combination of the following projects:

 * *Cactus* - maven plugins and build libraries
 * *KivaKit* - general purpose development kit
 * *MesaKit* - development kit for map data processing
 * *Lexakai* - automated UML and markdown documentation tool

> Note: The Maven `pom.xml` in this project is _bill of materials only_, and simply builds all child projects.  
> Since they are all built in the same [Maven reactor](https://books.sonatype.com/mvnref-book/reference/_using_advanced_reactor_options.html), breaking changes can be detected immediately.

> [**How to Build Telenav Open Source Projects**](documentation/building.md)

### Quick Start <a name = "quick-start"></a>&nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/rocket-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/rocket-32-2x.png 2x"/>

[**Setup**](documentation/initial-setup-instructions.md)  
[**Developing**](documentation/developing.md)  
[**Releasing**](documentation/releasing.md)

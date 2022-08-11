<!--suppress HtmlUnknownTarget, HtmlRequiredAltAttribute -->

Telenav Build &nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/gears-40.png" srcset="https://telenav.github.io/telenav-assets/images/icons/gears-40-2x.png 2x"/>
=============

This project combines all Telenav Open Source projects into a single parent repository 
using [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).  
This enables a single, consistent build of any combination of the following projects:

 * *Cactus* - maven plugins and build libraries
 * *KivaKit* - general purpose development kit
 * *MesaKit* - development kit for map data processing
 * *Lexakai* - automated UML and markdown documentation tool

## Build Status
| Repository and Branch                | Build Status                                                                                             |
|--------------------------------------|----------------------------------------------------------------------------------------------------------|
| `cactus develop`                     | <img src="https://github.com/Telenav/cactus/actions/workflows/build-develop.yml/badge.svg"/>             |
| `cactus release/current`             | <img src="https://github.com/Telenav/cactus/actions/workflows/build-release.yml/badge.svg"/>             |
| `kivakit develop`                    | <img src="https://github.com/Telenav/kivakit/actions/workflows/build-develop.yml/badge.svg"/>            |
| `kivakit release/current`            | <img src="https://github.com/Telenav/kivakit/actions/workflows/build-release.yml/badge.svg"/>            |
| `kivakit-extensions develop`         | <img src="https://github.com/Telenav/kivakit-extensions/actions/workflows/build-develop.yml/badge.svg"/> |
| `kivakit-extensions release/current` | <img src="https://github.com/Telenav/kivakit-extensions/actions/workflows/build-release.yml/badge.svg"/> |
| `kivakit-stuff develop`              | <img src="https://github.com/Telenav/kivakit-stuff/actions/workflows/build-develop.yml/badge.svg"/>      |
| `kivakit-stuff release/current`      | <img src="https://github.com/Telenav/kivakit-stuff/actions/workflows/build-release.yml/badge.svg"/>      |
| `kivakit-examples develop`           | <img src="https://github.com/Telenav/kivakit-examples/actions/workflows/build-develop.yml/badge.svg"/>   |
| `kivakit-examples release/current`   | <img src="https://github.com/Telenav/kivakit-examples/actions/workflows/build-release.yml/badge.svg"/>   |
| `lexakai develop`                    | <img src="https://github.com/Telenav/lexakai/actions/workflows/build-develop.yml/badge.svg"/>            |
| `lexakai release/current`            | <img src="https://github.com/Telenav/lexakai/actions/workflows/build-release.yml/badge.svg"/>            |
| `mesakit develop`                    | <img src="https://github.com/Telenav/mesakit/actions/workflows/build-develop.yml/badge.svg"/>            |
| `mesakit release/current`            | <img src="https://github.com/Telenav/mesakit/actions/workflows/build-release.yml/badge.svg"/>            |
| `mesakit-extensions develop`         | <img src="https://github.com/Telenav/mesakit-extensions/actions/workflows/build-develop.yml/badge.svg"/> |
| `mesakit-extensions release/current` | <img src="https://github.com/Telenav/mesakit-extensions/actions/workflows/build-release.yml/badge.svg"/> |
| `mesakit-examples develop`           | <img src="https://github.com/Telenav/mesakit-examples/actions/workflows/build-develop.yml/badge.svg"/>   |
| `mesakit-examples release/current`   | <img src="https://github.com/Telenav/mesakit-examples/actions/workflows/build-release.yml/badge.svg"/>   |


> Note: The Maven `pom.xml` in this project is _bill of materials only_, and simply builds all child projects.  
> Since they are all built in the same [Maven reactor](https://books.sonatype.com/mvnref-book/reference/_using_advanced_reactor_options.html), breaking changes can be detected immediately.

> [**How to Build Telenav Open Source Projects**](documentation/building.md)

### Quick Start <a name = "quick-start"></a>&nbsp; <img src="https://telenav.github.io/telenav-assets/images/icons/rocket-32.png" srcset="https://telenav.github.io/telenav-assets/images/icons/rocket-32-2x.png 2x"/>

[**Setup**](documentation/initial-setup-instructions.md)  
[**Developing**](documentation/developing.md)  
[**Releasing**](documentation/releasing.md)

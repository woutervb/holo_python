# Holo Python

This is a [micropython] version targeting the [holocube] from [fiberpunk].

What is means, is that this repo, will include the drivers needed to run all the components of the
holocube.

## Current status

| component              | should be working  | confirmed |
| ---------------------- | ------------------ | --------- |
| rgb led                | :heavy_check_mark: | :x:       |
| lcd                    | :x:                | :x:       |
| 3 axis tilt sensor     | :x:                | :x:       |
| helper for definitions | :x:                | :x:       |

## Helper for definitions

This will be a python file added, containing the pin information and some helper files, to ease the
initialisation of things like the sdcard reader, the rgb led etc.

## Licensing

**This** repository is licensed under GPL-2, the included external repositories are licensed under
their respective licenses.

- Micropython : MIT

[micropython]: https://micropython.org/
[holocube]: https://fiber-punk.com/products/fiberpunk-stl-preview-holocubic-diy-kit
[fiberpunk]: https://github.com/fiberpunk1/Holo

# Changelog

This changelog summarizes user-visible changes to `vindauga`. Older history has
been condensed from the commit log to remove duplicated entries and repository
maintenance noise.

## Unreleased

### Fixed

- Help output is now side-effect free. Running `vindauga.sh -h` or
  `vindauga.sh --help` no longer creates cache directories or copies assets
  before exiting.
- Startup now fails cleanly when the cache directory or cache symlink cannot be
  created, instead of continuing into a broken state and emitting follow-on
  file errors.
- Rounded-corner rendering no longer relies on a shared temporary MVG file in
  the working directory, which avoids race conditions and path-dependent
  failures.
- Rounded-corner rendering now avoids ImageMagick `@file` draw input, so it
  works on systems where that behavior is blocked by the default security
  policy.
- Reading `MPD_HOST` from `.bashrc` is now more selective and less likely to
  pick up comments, malformed assignments, or unrelated lines.
- First-run behavior no longer errors when `${XDG_CACHE_HOME}/vindauga/songinfo`
  does not exist yet.

### Changed

- The built-in help now documents only the options that actually exist. Unknown
  options return an error instead of being silently ignored.

## 2.0.1 - 2023-11-14

### Changed

- Simplified the project substantially by stripping out the older cover-finding
  workflow and focusing the script on locating and exporting the current album
  cover for display.
- Reduced unnecessary cover regeneration by checking whether the current song
  changed before rebuilding cached artwork.
- Refreshed the README and example `conky` configuration to match the simpler
  workflow.

## 2.0.0 - 2021-08-04

### Added

- Added a changelog and refreshed the bundled project documentation.

### Changed

- Reworked the project around the newer split between `vindauga` and
  `ffixer_covers`, with `vindauga` focused on displaying synchronized cover art.

## 1.0.2 - 2021-09-04

### Fixed

- Updated multi-MPD behavior to work with the newer `conky` format.

## 1.0.1 - 2021-08-04

### Fixed

- Improved INI/config handling used alongside the cover synchronization
  workflow.

## 1.0.0 - 2021-08-04

### Added

- First tagged 1.x release of the reworked `vindauga`/`ffixer_covers` era.

## 0.9.10 - 2020-08-27

### Fixed

- Corrected a cover lookup mistake that returned album artwork where artist
  artwork was expected for users of the older workflow.

## 0.9.9 - 2020-08-25

### Changed

- Improved `glyr` searches, including PNG input support, and added `glyr` as an
  additional source in the older artist-art lookup path.

## Pre-1.0 Highlights

### 2021-08 to 2021-07

- Added support for switching between multiple players and multiple MPD hosts.
- Adjusted the example `conky` integration to use MPD built-ins more cleanly.
- Continued separating cover-finding logic from the display script.

### 2020-07 to 2019-06

- Added MPD host handling and early multi-host support.
- Refined cache layout and `conky` integration.
- Added the initial help text, kill-switch behavior, and the first published
  versions of the script and documentation.

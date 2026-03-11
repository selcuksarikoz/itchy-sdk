# IPTVModule

Custom Nook module example that opens a dedicated IPTV panel.

## Features

- Nook tile launcher (`placement: .nookModule`)
- Dedicated floating panel
- Left channel list, right live video player
- Default playlist URL:
  `https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8`
- Playlist URL input for custom M3U/M3U8 sources
- 1-day local cache (manual `Refresh` bypasses cache)
- Channel logo rendering with TV placeholder fallback

## Files

- `IPTVModule.swift`: principal plugin class and metadata
- `IPTVModuleView.swift`: tile UI, panel UI, parser, cache, player logic
- `Info.plist`: bundle metadata and principal class


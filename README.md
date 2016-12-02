# screen-recorder

[![apm install screen-recorder](https://apm-badges.herokuapp.com/apm/screen-recorder.svg)](https://atom.io/packages/screen-recorder)

Record your atom editor into a gif.

![screen-recorder](https://cloud.githubusercontent.com/assets/10590799/14191540/8b7275f8-f755-11e5-8eae-931680f5a869.gif)

## Requirements
Before install be sure to have installed and in your `PATH`
[FFmpeg](https://www.ffmpeg.org/) and [ImageMagick](http://www.imagemagick.org/)

### Linux
* For Ubuntu/Debian use:
```bash
sudo apt-get install ffmpeg imagemagick
```

### Windows
Install ImageMagick from [here](http://www.imagemagick.org/script/binary-releases.php#windows), it already has ffmpeg.

### Mac
**This package has not support for OS X** (I don't have a mac to test it).

But PR are welcome :smile:

## Install
With apm:
```bash
apm install screen-recorder
```
Or Settings ➔ Packages ➔ Search for `screen-recorder`

## Commands

### Screen Recorder: Record Window
Records the entire atom workspace
### Screen Recorder: Record Tree View
Records the tree view
### Screen Recorder: Record Active Pane
Records the current active pane
### Screen Recorder: Open Select Area
Opens a layer when you can select the area to record
### Screen Recorder: Stop Recording
Stops the current recording and saves it into a gif
### Screen Recorder: Cancel Recording
Stops the current recording and saves nothing

## Settings

### Target Directory
Directory where screen recordings will be saved

### Reduce Output
Reduce the generated gif size

**Disable it if you have performance issues.**

### Frames Per Second
Frames per second used in the animated gif

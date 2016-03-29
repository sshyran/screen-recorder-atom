{CompositeDisposable} = require 'atom'

module.exports =
  isSupported: ->
    true

  setupFfmpegCmd: (ffmpegCmd, dimensions) ->
    ffmpegCmd
      .input 'desktop'
      .inputOptions [
        '-f gdigrab'
        "-video_size #{dimensions.w}x#{dimensions.h}"
        "-offset_x #{dimensions.x}"
        "-offset_y #{dimensions.y}"
        '-show_region 1'
      ]

  handleDimensions: (x, y, w, h) ->
    menubar = atom.getSize().height - document.documentElement.offsetHeight
    aP = atom.getPosition()
    {x: x + aP.x, y: y + aP.y + menubar, w: w, h: h}

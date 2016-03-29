{CompositeDisposable} = require 'atom'

module.exports =
  isSupported: ->
    true

  setupFfmpegCmd: (ffmpegCmd, dimensions) ->
    ffmpegCmd
      .input ":0.0+#{dimensions.x},#{dimensions.y}"
      .inputOptions [
        '-f x11grab',
        "-video_size #{dimensions.w}x#{dimensions.h}"
      ]

  handleDimensions: (x, y, w, h) ->
    menubar = atom.getSize().height - document.documentElement.offsetHeight
    aP = atom.getPosition()
    {x: x + aP.x, y: y + aP.y + menubar, w: w, h: h}

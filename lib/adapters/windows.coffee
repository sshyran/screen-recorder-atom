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
    aP = atom.getPosition()
    wDiff = (window.outerWidth - window.innerWidth) / 2
    hDiff = (window.outerHeight - window.innerHeight) / 2
    isMenubar = hDiff > 20
    if isMenubar
      frame = atom.getSize().height - document.documentElement.offsetHeight - 8
      frame = frame - (aP.y * 2) if atom.isMaximized()
      aPx = if atom.isMaximized() then 0 else aP.x
      aPy = if atom.isMaximized() then 0 else aP.y
      x = x + aPx + wDiff
      y = y + aPy + frame
      y = y - hDiff if atom.isMaximized()
      h = h + (aP.y / 2) if atom.isMaximized()
    else
      aPx = if atom.isMaximized() then 0 else aP.x
      aPy = if atom.isMaximized() then 0 else aP.y
      x = x + aPx + wDiff
      y = y + aPy + (hDiff * 2)
      y = y - 8 if not atom.isMaximized()

    {x: x, y: y, w: w, h: h}

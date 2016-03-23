{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class ScreenRecorderSelectAreaView extends View
  recorderManager = null

  @content: ->
    @div class: 'screen-recorder-select-area', tabindex: -1, =>
      @div outlet: 'ghostSelect', class: 'ghost-select', =>
        @span()

  constructor: (recorderManager) ->
    @recorderManager = recorderManager
    super

  initialize: ->
    @subscriptions = new CompositeDisposable
    @handleEvents()

  destroy: ->
    @remove()
    @subscriptions?.dispose()

  handleEvents: ->
    @subscriptions.add atom.commands.add @element,
      'screen-recorder:close-select-area': => @hide()

    @on 'mousedown', (e) =>
      @ghostSelect.css({
        'left': e.pageX,
        'top': e.pageY
      })
      @ghostSelect.css({
        'width': 0,
        'height': 0
      })
      @ghostSelect.addClass 'ghost-active'

      @initialW = e.pageX
      @initialH = e.pageY

      document.addEventListener 'mousemove', @updateGhostSelect
      document.addEventListener 'mouseup', @handleGhostSelect

  updateGhostSelect: (e) =>
    w = Math.abs(@initialW - e.pageX)
    h = Math.abs(@initialH - e.pageY)

    @ghostSelect.css({
      'width': w,
      'height': h
    })

    if e.pageX <= @initialW && e.pageY >= @initialH
      @ghostSelect.css({
        'left': e.pageX
      })
    else if e.pageY <= @initialH && e.pageX >= @initialW
      @ghostSelect.css({
        'top': e.pageY
      })
    else if e.pageY < @initialH && e.pageX < @initialW
      @ghostSelect.css({
        'left': e.pageX,
        'top': e.pageY
      })

  handleGhostSelect: (e) =>
    document.removeEventListener 'mousemove', @updateGhostSelect
    document.removeEventListener 'mouseup', @handleGhostSelect
    @ghostSelect.removeClass 'ghost-active'
    @ghostSelect.css({
      'width': 0,
      'height': 0
    })
    @hide()

    w = Math.abs(@initialW - e.pageX)
    h = Math.abs(@initialH - e.pageY)
    x = if e.pageX <= @initialW then e.pageX else @initialW
    y = if e.pageY <= @initialH then e.pageY else @initialH
    aP = atom.getPosition()

    @startRecording x + aP.x, y + aP.y, w, h

  hide: ->
    for panel in atom.workspace.getModalPanels()
      panel.hide() if panel.className is 'screen-recorder-select-area-panel'
    atom.workspace.getActivePane().activate()

  startRecording: (x, y, w, h) ->
    @recorderManager.startRecording x, y, w, h

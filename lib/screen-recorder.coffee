ScreenRecorderSelectAreaView = require './screen-recorder-select-area-view'
ScreenRecorderRecorderManager = require './recorder-manager'
{requirePackages} = require 'atom-utils'
{CompositeDisposable} = require 'atom'

module.exports = ScreenRecorder =
  selectAreaView: null
  recorderManager: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @recorderManager = new ScreenRecorderRecorderManager
    @selectAreaView = new ScreenRecorderSelectAreaView @recorderManager

    @modalPanel = atom.workspace.addModalPanel
      item: @selectAreaView
      visible: false
      className: 'screen-recorder-select-area-panel'

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'screen-recorder:open-select-area': => @openSelectArea()
      'screen-recorder:record-window': => @recordWindow()
      'screen-recorder:record-tree-view': => @recordTreeView()
      'screen-recorder:record-active-pane': => @recordActivePane()
      'screen-recorder:stop-recording': => @stopRecording()
      'screen-recorder:cancel-recording': => @cancelRecording()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @selectAreaView.destroy()

  serialize: ->

  openSelectArea: ->
    if @recorderManager.isRecording()
      atom.notifications.addWarning "There is already a recording active"
    else
      @modalPanel.show()
      @modalPanel.item.focus()

  recordWindow: ->
    p = atom.getPosition()
    s = atom.getSize()
    @recorderManager.startRecording p.x, p.y, s.width, s.height

  recordTreeView: ->
    requirePackages('tree-view').then ([treeView]) =>
      treeView = treeView.treeView
      p = treeView.offset()
      @recorderManager.startRecording p.left, p.top, treeView.width(), treeView.height()

  recordActivePane: ->
    atom.workspace.getActivePane()
    paneElement = atom.views.getView(pane)
    r = paneElement.getBoundingClientRect()
    @recorderManager.startRecording r.left, r.top, r.bottom - r.top, r.right - r.left

  stopRecording: ->
    @recorderManager.stopRecording()

  cancelRecording: ->
    @recorderManager.cancelRecording()

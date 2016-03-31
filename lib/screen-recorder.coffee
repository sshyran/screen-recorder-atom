SelectAreaView = require './views/select-area-view'
RecorderManager = require './recorder-manager'
path = require 'path'
fs = require 'fs-plus'
{requirePackages} = require 'atom-utils'
{CompositeDisposable} = require 'atom'

module.exports = ScreenRecorder =
  config:
    targetDirectory:
      type: 'string'
      default: path.join fs.getHomeDirectory(), 'atomrecordings'
      description: 'Directory where screen recordings will be saved.'

  selectAreaView: null
  statusView: null
  recorderManager: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @recorderManager = new RecorderManager

    if not @recorderManager.canBeEnabled()
      atom.notifications
        .addWarning 'screen-recorder does not support your operative system yet'
      @deactivate()
      return

    @selectAreaView = new SelectAreaView @recorderManager

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
    @modalPanel?.destroy()
    @subscriptions?.dispose()
    @selectAreaView?.destroy()
    @statusView?.destroy()

  serialize: ->

  consumeStatusBar: (statusBar) ->
    StatusView = require './views/status-view'
    @statusView = new StatusView
    @statusView.setStatusBar statusBar
    @recorderManager.setStatusView @statusView

  openSelectArea: ->
    if @recorderManager.isRecording()
      atom.notifications.addWarning "There is already a recording active"
    else
      @modalPanel.show()
      @modalPanel.item.focus()

  recordWindow: ->
    w = document.documentElement.offsetWidth
    h = document.documentElement.offsetHeight
    @recorderManager.startRecording 0, 0, w, h

  recordTreeView: ->
    requirePackages('tree-view').then ([treeView]) =>
      treeView = treeView.treeView
      p = treeView.offset()
      @recorderManager
        .startRecording p.left, p.top, treeView.width(), treeView.height()

  recordActivePane: ->
    pane = atom.workspace.getActivePane()
    paneElement = atom.views.getView(pane)
    r = paneElement.getBoundingClientRect()
    @recorderManager
      .startRecording r.left, r.top,  r.right - r.left, r.bottom - r.top

  stopRecording: ->
    @recorderManager.stopRecording()

  cancelRecording: ->
    @recorderManager.cancelRecording()

ScreenRecorderSelectAreaView = require './screen-recorder-select-area-view'
{CompositeDisposable} = require 'atom'

module.exports = ScreenRecorder =
  screenRecorderSelectAreaView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @screenRecorderSelectAreaView = new ScreenRecorderSelectAreaView

    @modalPanel = atom.workspace.addModalPanel
      item: @screenRecorderSelectAreaView
      visible: false
      className: 'screen-recorder-select-area-panel'

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'screen-recorder:open-select-area': => @openSelectArea()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @screenRecorderSelectAreaView.destroy()

  serialize: ->

  openSelectArea: ->
    @modalPanel.show()
    @modalPanel.item.focus()

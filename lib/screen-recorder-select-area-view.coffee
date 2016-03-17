{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class ScreenRecorderSelectAreaView extends View
  @content: ->
    @div class: 'screen-recorder-select-area', tabindex: -1

  initialize: ->
    @subscriptions = new CompositeDisposable
    @handleEvents()

  destroy: ->
    @remove()
    @subscriptions?.dispose()

  handleEvents: ->
    @subscriptions.add atom.commands.add @element,
      'screen-recorder:close-select-area': => @hide()

  hide: ->
    for panel in atom.workspace.getModalPanels()
      panel.hide() if panel.className is 'screen-recorder-select-area-panel'
    atom.workspace.getActivePane().activate()

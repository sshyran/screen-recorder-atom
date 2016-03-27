{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class ScreenRecorderStatusView extends View
  @content: ->
    @div class: 'screen-recorder-status inline-block', =>
      @span class: 'icon icon-device-camera-video'
      @span outlet: 'timer', class: 'screen-recorder-timer'

  initialize: ->
    @subscriptions = new CompositeDisposable

  destroy: ->
    @remove()
    @subscriptions?.dispose()

  startTimer: ->
    @startTime = new Date
    @timer.text '0s'
    @timeout = setTimeout (=> @updateTimer()), 1000

  updateTimer: ->
    seconds = parseInt ((new Date) - @startTime) / 1000
    @timer.text seconds + 's'
    @timeout = setTimeout (=> @updateTimer()), 1000

  setStatusBar: (statusBar) ->
    @statusBar = statusBar

  show: ->
    @tile = @statusBar.addRightTile(item: @element, priority: 5000)
    @startTimer()

  hide: ->
    clearTimeout @timeout
    @tile.destroy()

  saving: ->
    clearTimeout @timeout
    @timer.text 'Saving...'

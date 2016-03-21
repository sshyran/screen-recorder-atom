{CompositeDisposable} = require 'atom'

module.exports = ->
  isRecording = false

  startRecording: (x, y, w, h) ->
    if isRecording
      atom.notifications.addWarning "There is already a recording active"
    else
      atom.notifications.addInfo "Recording started from #{x},#{y} with size #{w}x#{h}"
      isRecording = true

  stopRecording: ->
    if isRecording
      atom.notifications.addSuccess 'Recording saved'
      isRecording = false
    else
      atom.notifications.addWarning "There is not a recording active"

  cancelRecording: ->
    if isRecording
      atom.notifications.addInfo 'Recording canceled'
      isRecording = false
    else
      atom.notifications.addWarning "There is not a recording active"

  isRecording: ->
    isRecording

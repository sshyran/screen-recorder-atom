ffmpeg = require('fluent-ffmpeg')
path = require 'path'
fs = require 'fs-plus'
{CompositeDisposable} = require 'atom'

module.exports = ->
  isRecording = false

  setStatusView: (statusView) ->
    @statusView = statusView

  startRecording: (x, y, w, h) ->
    if isRecording
      atom.notifications.addWarning "There is already a recording active"
    else
      @setNewFilePath()
      @ffmpegCommand = ffmpeg()
        .addOptions [
          '-pix_fmt rgb24'
          "-filter:v scale=-1:#{h}"
        ]
        .size "#{w}x#{h}"
        .fps 20
        .input ":0.0+#{x},#{y}"
        .inputOptions [
          '-f x11grab',
          "-video_size #{w}x#{h}"
        ]
        .on 'error', (e) ->
          throw e if e.message.indexOf('SIGKILL') < 0
        .save @filePath

      atom.notifications.addInfo "Recording started from #{x},#{y} with size #{w}x#{h}"
      isRecording = true
      @statusView.show()

  stopRecording: ->
    if isRecording
      @ffmpegCommand.kill()
      atom.notifications.addSuccess 'Recording saved'
      isRecording = false
      @statusView.hide()
      atom.workspace.open @filePath
    else
      atom.notifications.addWarning "There is not a recording active"

  cancelRecording: ->
    if isRecording
      @ffmpegCommand.kill()
      fs.removeSync @filePath
      atom.notifications.addInfo 'Recording canceled'
      isRecording = false
      @statusView.show()
    else
      atom.notifications.addWarning "There is not a recording active"

  isRecording: ->
    isRecording

  setNewFilePath: ->
    dir = atom.config.get 'screen-recorder.targetDirectory'
    fs.makeTreeSync dir if not fs.isDirectorySync dir
    @filePath = path.join dir, Date.now() + '.gif'

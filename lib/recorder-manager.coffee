ffmpeg = require 'fluent-ffmpeg'
im = require 'imagemagick'
path = require 'path'
fs = require 'fs-plus'
{CompositeDisposable} = require 'atom'

module.exports = ->
  isRecording = false
  isSaving = false

  setStatusView: (statusView) ->
    @statusView = statusView

  startRecording: (x, y, w, h) ->
    if isRecording
      atom.notifications.addWarning "There is already a recording active"
    else
      @setPaths()
      @ffmpegCommand = ffmpeg()
        .addOptions [
          '-pix_fmt rgb24'
          "-filter:v scale=-1:#{h}:flags=lanczos"
        ]
        .size "#{w}x#{h}"
        .fps 20
        .input ":0.0+#{x},#{y}"
        .inputOptions [
          '-f x11grab',
          "-video_size #{w}x#{h}"
        ]
        .on 'error', (error) =>
          if error.message.indexOf('SIGKILL') < 0
            fs.removeSync @tmpDir
            isRecording = false
            @statusView.hide()
            throw error
        .save @tmpFilesSave

      atom.notifications.addInfo "Recording started from #{x},#{y} with size #{w}x#{h}"
      isRecording = true
      @statusView.show()

  stopRecording: ->
    if isRecording and not isSaving
      isSaving = true
      @ffmpegCommand.kill()
      @statusView.saving()

      im.convert [
        '-loop', '0'
        '-delay', '5'
        '-coalesce'
        @tmpFilesRead
        '-layers', 'Optimize'
        @filePath
      ], (error) =>
        fs.removeSync @tmpDir
        isRecording = false
        isSaving = false
        @statusView.hide()
        if error?
          throw error
        else
          atom.notifications.addSuccess 'Recording saved'
          atom.workspace.open @filePath

    else
      atom.notifications.addWarning "There is not a recording active"

  cancelRecording: ->
    if isRecording and not isSaving
      @ffmpegCommand.kill()
      fs.removeSync @tmpDir
      atom.notifications.addInfo 'Recording canceled'
      isRecording = false
      @statusView.hide()
    else
      atom.notifications.addWarning "There is not a recording active"

  isRecording: ->
    isRecording

  setPaths: ->
    dir = atom.config.get 'screen-recorder.targetDirectory'
    @tmpDir = path.join dir, 'tmp'
    fs.makeTreeSync @tmpDir if not fs.isDirectorySync @tmpDir
    @filePath = path.join dir, Date.now() + '.gif'
    @tmpFilesSave = path.join @tmpDir, 'ffout%03d.png'
    @tmpFilesRead = path.join @tmpDir, 'ffout*.png'

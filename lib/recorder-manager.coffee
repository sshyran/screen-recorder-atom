ffmpeg = require 'fluent-ffmpeg'
im = require 'imagemagick'
path = require 'path'
fs = require 'fs-plus'
{CompositeDisposable} = require 'atom'

module.exports =
class RecorderManager
  isRecording = false
  isSaving = false
  adapter = null

  constructor: ->
    switch process.platform
      when 'linux' then @adapter = require './adapters/linux'
      when 'win32' then @adapter = require './adapters/windows'
      when 'darwin' then @adapter = require './adapters/mac'

  canBeEnabled: ->
    @adapter?.isSupported()

  setStatusView: (statusView) ->
    @statusView = statusView

  startRecording: (x, y, w, h) ->
    if isRecording
      atom.notifications.addWarning "There is already a recording active"
    else
      @setPaths()
      @ffmpegCmd = ffmpeg()
        .addOptions [
          '-pix_fmt rgb24'
          "-filter:v scale=-1:#{h}:flags=lanczos"
        ]
        .size "#{w}x#{h}"
        .fps 20
        .on 'error', (error) =>
          if error.message.indexOf('SIGKILL') < 0
            fs.removeSync @tmpDir
            isRecording = false
            @statusView.hide()
            throw error

      dimensions = @adapter.handleDimensions x, y, w, h

      for k, v of dimensions
        dimensions[k] = parseInt v, 10

      @adapter.setupFfmpegCmd @ffmpegCmd, dimensions
      @ffmpegCmd.save @tmpFilesSave

      atom.notifications.addInfo "Recording started from #{x},#{y} with size #{w}x#{h}"
      isRecording = true
      @statusView.show()

  stopRecording: ->
    if isRecording and not isSaving
      isSaving = true
      @ffmpegCmd.kill()
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
      @ffmpegCmd.kill()
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

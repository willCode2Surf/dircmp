fs = require 'fs'
async = require 'async'
wrench = require 'wrench'
path = require 'path'
mkdirp = require 'mkdirp'
should = require 'should'
dircmp = require 'src/dircmp'

TEST_DIR = 'test_folder'

describe 'dircmp', ->
  #describe '#cmp', ->
  describe '#hash', ->
    before (ready) -> create(TEST_DIR, ready)
    it 'should generate hash', (done) ->
      dircmp.hash TEST_DIR, (err, hash) ->
        should.not.exist(err)
        should.exist(hash)
        done()
    it 'should generate same hash each time for same file', (done) ->
      async.map [TEST_DIR, TEST_DIR], dircmp.hash, (err, hashes) ->
        should.not.exist(err)
        hashes.should.have.length(2)
        hashes[0].should.eql hashes[1]
        done()
    after (done) -> destroy(TEST_DIR, done)

create = (dir, callback) ->
  folders = [
    '.git'
    'a/b/c/d'
  ]
  files = [
    '.git/config'
    'a/b/c/d/e.txt'
    'a/b/c/d/t.txt'
    '.gitignore'
  ]
  folders = folders.map (folder) -> path.join(dir, folder)
  files = files.map (file) -> path.join(dir, file)

  async.series [
    (callback) ->
      async.map(folders, mkdirp, callback)
    (callback) ->
      async.map(files, randomFile, callback)
  ], callback

destroy = (dir, callback) ->
  wrench.rmdirRecursive(dir, callback)

randomFile = (path, callback) ->
  fs.writeFile(path, Math.random().toString(), callback)
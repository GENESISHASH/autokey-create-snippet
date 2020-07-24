_ = require('wegweg')(globals:on)

slugify = require 'slugify'

Liquid = (require 'liquidjs').Liquid
liquid = new Liquid()

DOTFILE_BULK = _.reads __dirname + '/.template.json'

create = ((opt,cb) ->
  required = [
    'partial'
    'content'
  ]

  for x in required
    if !opt[x] then return cb new Error "#{x} required"

  opt.partial = opt.partial.trim()
  opt.content = opt.content.trim()

  opt.slug = slugify(opt.partial,{
    strict: true
    lower: true
    replacement: '-'
  })

  data = {}

  await _render DOTFILE_BULK, opt, defer e,data.dotfile
  if e then return cb e

  data.txtfile = opt.content

  if opt.outdir
    opt.outdir = require('path').resolve(opt.outdir)

  if opt.outdir and _.exists(opt.outdir) and _.is_folder(opt.outdir)
    prefix = require('path').resolve(opt.outdir)
  else
    prefix = __dirname + '/out'
    if !_.exists(prefix) then mkdir prefix

  _.writes (uno = prefix + '/' + '.' + opt.slug + '.json'), data.dotfile
  _.writes (dos = prefix + '/' + opt.slug + '.txt'), data.txtfile

  log 'Wrote file', uno
  log 'Wrote file', dos

  return cb null, true
)

_render = (bulk,data,cb) ->
  liquid.parseAndRender(bulk,data)
    .then (r) ->
      return cb null,r
    .catch (e) ->
      return cb e

##
module.exports = create

###
await create {
  partial: 'weg'
  content: """
    _ = require('wegweg')({globals:off})
  """
}, defer e
if e then throw e

log 'Finished'
process.exit 0
###


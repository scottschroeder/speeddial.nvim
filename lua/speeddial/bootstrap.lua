if SpeeddialGlobal and SpeeddialGlobal.bootstrap_done then
  return SpeeddialGlobal.bootstrap_ok
end

local lazy = require("speeddial.lazy")

local EventEmitter = lazy.access("speeddial.events", "EventEmitter") ---@type EventEmitter|LazyModule
local Logger = lazy.access("speeddial.logger", "Logger") ---@type Logger|LazyModule
local speeddial = lazy.require("speeddial") ---@module "speeddial"
local utils = lazy.require("speeddial.utils") ---@module "speeddial.utils"

local uv = vim.loop

local function err(msg)
  msg = msg:gsub("'", "''")
  vim.cmd("echohl Error")
  vim.cmd(string.format("echom '[speeddial.nvim] %s'", msg))
  vim.cmd("echohl NONE")
end

_G.SpeeddialGlobal = {
  bootstrap_done = true,
  bootstrap_ok = false,
}

if vim.fn.has("nvim-0.7") ~= 1 then
  err(
    "Minimum required version is Neovim 0.7.0! Cannot continue."
  )
  return false
end

_G.SpeeddialGlobal = {
  ---Debug Levels:
  ---0:     NOTHING
  ---1:     NORMAL
  ---5:     LOADING
  ---10:    RENDERING & ASYNC
  ---@diagnostic disable-next-line: missing-parameter
  debug_level = tonumber((uv.os_getenv("DEBUG_speeddial"))) or 0,
  state = {},
  bootstrap_done = true,
  bootstrap_ok = true,
}

SpeeddialGlobal.logger = Logger()
SpeeddialGlobal.emitter = EventEmitter()

SpeeddialGlobal.emitter:on_any(function(e, args)
  speeddial.nore_emit(e.id, utils.tbl_unpack(args))
end)

return true

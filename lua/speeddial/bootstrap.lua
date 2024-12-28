if SpeeddialGlobal and SpeeddialGlobal.bootstrap_done then
  return SpeeddialGlobal.bootstrap_ok
end

local log = require("speeddial.log")

_G.SpeeddialGlobal = {
  bootstrap_done = true,
  bootstrap_ok = false,
}

if vim.fn.has("nvim-0.7") ~= 1 then
  log.error(
    "Minimum required version is Neovim 0.7.0! Cannot continue."
  )
  return false
end

---Debug Levels:
--- "trace"
--- "debug"
--- "info"
--- "warn"
--- "error"
--- "fatal"
---@diagnostic disable-next-line: missing-parameter
local debug_level = vim.loop.os_getenv("DEBUG_speeddial") or "error"

local logger = log.new({ level = debug_level }, true)

_G.SpeeddialGlobal = {
  debug_level = debug_level,
  state = {},
  bootstrap_done = true,
  bootstrap_ok = true,
  logger = logger,
}

log.trace("bootstrap complete")

return true

if not require("speeddial.bootstrap") then
  return
end

local lazy = require("speeddial.lazy")

local config = lazy.require("speeddial.config") ---@module "speeddial.config"
-- local lib = lazy.require("speeddial.lib") ---@module "speeddial.lib"
local utils = lazy.require("speeddial.utils") ---@module "speeddial.utils"

local api = vim.api
local logger = SpeeddialGlobal.logger
local pl = lazy.access(utils, "path") ---@type PathLib

local M = {}

function M.setup(user_config)
  config.setup(user_config or {})
end

function M.init()
end

M.init()

return M

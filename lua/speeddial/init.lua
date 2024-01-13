if not require("speeddial.bootstrap") then
  return
end

local lazy = require("speeddial.lazy")
local src_loader = lazy.require("speeddial.lib.source") ---@module "speeddial.lib.source"
local speeddial_select = lazy.require("speeddial.lib.select") ---@module "speeddial.lib.select"

local config = lazy.require("speeddial.config") ---@module "speeddial.config"
-- local lib = lazy.require("speeddial.lib") ---@module "speeddial.lib"
local utils = lazy.require("speeddial.utils") ---@module "speeddial.utils"

local api = vim.api
local logger = SpeeddialGlobal.logger
local DB = SpeeddialGlobal.DB
local pl = lazy.access(utils, "path") ---@type PathLib

local M = {}

function M.setup(user_config)
  config.setup(user_config or {})
  local cfg = config.get_config()
  src_loader.load_sources(DB, cfg.sources)
end

function M.init()
end

M.init()

function M.hello()
  for k, v in pairs(DB:projects()) do
    logger:info("proj kv", k, v)
  end
end

function M.select(opts)
  opts = opts or {}
  speeddial_select.select_impl(DB, opts)
end

return M

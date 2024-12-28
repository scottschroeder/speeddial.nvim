require("speeddial.bootstrap")

local log = require("speeddial.log")

-- local src_loader = require("speeddial.lib.source") ---@module "speeddial.lib.source"
-- local speeddial_select = require("speeddial.lib.select") ---@module "speeddial.lib.select"

local config = require("speeddial.config") ---@module "speeddial.config"



local M = {}

function M.setup(user_config)
  config.setup(user_config or {})
  local cfg = config.get_config()
  log.trace("config", cfg)
  -- src_loader.load_sources(DB, cfg.sources)
end

function M.hello()
  local cfg = config.get_config()
  log.info(cfg)

  log.trace("trace log line")
  log.debug("debug log line")
  log.info("info log line")
  log.warn("warn log line")
  log.error("error log line")
  log.fatal("fatal log line")

  -- for k, v in pairs(DB:projects()) do
  --   logger:info("proj kv", k, v)
  -- end
end

function M.select(opts)
  opts = opts or {}
  -- speeddial_select.select_impl(DB, opts)
end

return M

require("speeddial.bootstrap")

local log = require("speeddial.log")

-- local src_loader = require("speeddial.lib.source") ---@module "speeddial.lib.source"
local speeddial_select = require("speeddial.lib.select")

local config = require("speeddial.config") ---@module "speeddial.config"



local M = {}

function M.setup(user_config)
  config.setup(user_config or {})
  local cfg = config.get_config()
  log.trace("config", cfg)
  local projectdb = require("speeddial.lib.projectdb")
  -- TODO cfg into create db
  SpeeddialGlobal.state.db = projectdb.create_db()

  local source = require("speeddial.lib.source")
  local import_cb = source._create_project_importer(SpeeddialGlobal.state.db)
  source.load_all_sources(cfg.sources, import_cb)
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


  local projectdb = require("speeddial.lib.projectdb")
  local db = projectdb.create_db()

  local source = require("speeddial.lib.source")
  local import_cb = source._create_project_importer(db)
  source.fetch_source({
    project = {
      name = "test",
      root = "~/src/test",
      vcs_root = "~/src/test",
    }
  }, import_cb)

  source.fetch_source({
    git = {
      name = "projects",
      base = "~/src/github/scottschroeder",
    }
  }, import_cb)

  local timer = vim.loop.new_timer()
  timer:start(2000, 0, vim.schedule_wrap(function()
    for k, v in pairs(db.projects) do
      log.info("proj k", k)
    end
  end))
end

---Wait for all pending jobs to finish.
---Will wait at most `timeout`, checking every 20ms.
---In practice, this typically takes <150ms, and is not
---noticeable to the user
---@param timeout integer: timeout in milliseconds
local wait_for_jobs = function(timeout)
  vim.wait(timeout, function()
    return SpeeddialGlobal.state.pending_jobs == 0
  end, 20)
end

function M.select(opts)
  wait_for_jobs(5000)

  speeddial_select.select_impl(SpeeddialGlobal.state.db, opts)
end

return M

local logger = SpeeddialGlobal.logger

local Project = require("speeddial.lib.project").Project

-- project
-- name,
-- root,
-- vcs_root
-- source or config
-- vcs
-- base
-- source or git
--
--

local M = {}

---@param cfg table|nil
---@return Project
local load_project = function(cfg)
  cfg = cfg or {}
  cfg.source = cfg.source or "config"
  return Project(cfg)
end

---@param source_cfg table
---@return Project[]
function M.load_sources(source_cfg)
  local projects = {}
  for _, cfg in ipairs(source_cfg) do
    if cfg.project ~= nil then
      projects[#projects + 1] = load_project(cfg.project)
    else
      logger:warn("unknown source config", cfg)
    end
  end
  return projects
end

return M

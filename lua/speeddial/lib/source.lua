local Job = require("plenary.job")

local logger = SpeeddialGlobal.logger
local Project = require("speeddial.lib.project").Project
local fs = require("speeddial.lib.fs")
local gitutil = require("speeddial.lib.gitutil")

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

M.extract_title = function(root, opts)
  opts = opts or {}
  -- local title_depth = opts.title_depth or 2
  local title = gitutil.parse_repo_name_from_git_path(root)

  if title == nil then
    local components = vim.split(root:absolute(), "/")
    return components[#components]
  end

  return title
end

---@param db ProjectDB
local kickoff_fetch = function(db, base_dir, opts)
  opts = opts or {}
  local source = opts.source or "git"
  logger:info("source", source)

  local p = fs.normalize(base_dir)
  -- fd -H --base-directory ~/src --type d '\.git$' . -x echo {//}
  Job:new({
    command = "fd",
    args = {
      '-H',
      '--base-directory',
      p:absolute(),
      '--type',
      'd',
      '\\.git$',
      '.',
      '-x',
      'echo',
      '{//}'
    },
    on_exit = function(j, return_val)
      if return_val > 0 then
        logger:warn("unable to run `fd`")
        return
      end
      for _, project in pairs(j:result()) do
        local project_dir = base_dir .. "/" .. project
        local project_path = fs.normalize(project_dir)

        local title = M.extract_title(project_path, opts)

        db:add(Project({
          title = title,
          root = project_dir,
          vcs_root = project_dir,
          source = source,
        }))
      end
    end,
  }):start()
end

---@param db ProjectDB
---@param source_cfg table
---@return Project[]
function M.load_sources(db, source_cfg)
  for _, cfg in ipairs(source_cfg) do
    if cfg.project ~= nil then
      db:add(load_project(cfg.project))
    elseif cfg.git ~= nil then
      if cfg.git.root == nil then
        logger:warn("git source missing root", cfg)
      else
        logger:info("git cfg", cfg.git)
        kickoff_fetch(db, cfg.git.root, cfg.git)
      end
    else
      logger:warn("unknown source config", cfg)
    end
  end
end

return M

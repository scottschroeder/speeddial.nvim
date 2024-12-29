local log = require("speeddial.log")
local gitutil = require("speeddial.lib.gitutil")
local Job = require("plenary.job")
local project = require("speeddial.lib.project")
local projectdb = require("speeddial.lib.projectdb")
local normalize = require("speeddial.lib.fs").normalize

---@class speeddial.lib.source.Source
---@field git speeddial.lib.source.GitSource|nil
---@field project speeddial.lib.source.ProjectSource|nil

---@class speeddial.lib.source.GitSource
---@field title string: short descriptive name
---@field base string: the directory to scan for git repos
---@field depth integer|nil: how deep we should scan for git repos
---@field source string|nil: the type of source (default git)

---@class speeddial.lib.source.ProjectSource
---@field title string: short descriptive name
---@field root string|nil: the directory for CWD
---@field vcs_root string|nil: the directory containing the VCS root
---@field source string|nil: the directory containing the VCS root

--- @alias Importer fun(p: speeddial.lib.project.Project): nil

---@param cfg speeddial.lib.source.ProjectSource
---@return speeddial.lib.project.Project
local configured_project = function(cfg)
  cfg = cfg or {}
  cfg.source = cfg.source or "config"
  return project.new_project(cfg)
end

---@param import_cb Importer
---@param title_cb fun(vcs_root: Path):string
---@return fun(cfg: speeddial.lib.source.GitSource, path: string): nil
local vcs_importer = function(import_cb, title_cb)
  return function(cfg, path)
    local base = normalize(cfg.base)
    local project_path = base:joinpath(path)
    local title = title_cb(project_path)
    local p = project.new_project({
      title = title,
      root = project_path,
      vcs_root = project_path,
      source = cfg.source,
    })
    import_cb(p)
  end
end

---Get the title of a project from it's path on the filesystem
---@param vcs_root Path
---@return string
local title_fs_extractor = function(vcs_root)
  local title = gitutil.parse_repo_name_from_git_repo(vcs_root)

  if title == nil then
    local components = vim.split(vcs_root:absolute(), "/")
    return components[#components]
  end

  return title
end

---Create the default callback which reads a git repo on disk
---@param import_cb Importer
---@return fun(cfg: speeddial.lib.source.GitSource, path: string):nil
local default_git_cb = function(import_cb)
  return vcs_importer(import_cb, title_fs_extractor)
end

---Scan the filesystem for git repos, and import the projects
---@param cfg speeddial.lib.source.GitSource
---@param callback fun(cfg: speeddial.lib.source.GitSource, path: string): nil
local git_import = function(cfg, callback)
  if cfg.source == nil then
    cfg.source = "git"
  end
  if cfg.base == nil or cfg.base == "" then
    log.warn("no base directory for git scan")
    return
  end
  local base_path_str = normalize(cfg.base):absolute()
  log.info("begin git scan of source", cfg.source, "in", base_path_str, "cfg:", cfg)


  local args = {
    '-H',
    '--base-directory',
    base_path_str,
    '--type',
    'd',
  }

  local args2 = {
    '\\.git$',
    '.',
    '-x',
    'echo',
    '{//}'
  }

  if cfg.depth then
    table.insert(args, "-d")
    table.insert(args, cfg.depth + 1)
  end

  for _, v in pairs(args2) do
    table.insert(args, v)
  end

  log.debug("running fd with args", args)

  SpeeddialGlobal.state.pending_jobs = SpeeddialGlobal.state.pending_jobs + 1
  Job:new({
    command = "fd",
    args = args,
    on_exit = function(j, return_val)
      vim.schedule(function()
        log.trace("fd result ret:", return_val, "job:", j)
      end)
      if return_val > 0 then
        vim.schedule(function()
          log.warn("unable to run `fd`")
        end)
        SpeeddialGlobal.state.pending_jobs = SpeeddialGlobal.state.pending_jobs - 1
        return
      end
      vim.schedule(function()
        for _, p in pairs(j:result()) do
          callback(cfg, p)
        end
        SpeeddialGlobal.state.pending_jobs = SpeeddialGlobal.state.pending_jobs - 1
      end)
    end
  }):start()
end

local M = {}

---@param cfg speeddial.lib.source.Source
---@param import_cb Importer
M.fetch_source = function(cfg, import_cb)
  if cfg.project ~= nil then
    local p = configured_project(cfg.project)
    import_cb(p)
  elseif cfg.git ~= nil then
    local cb = default_git_cb(import_cb)
    return git_import(cfg.git, cb)
  else
    log.warn("unknown source config", cfg)
  end
end

---@param db speeddial.lib.projectdb.ProjectDB
---@return Importer
M._create_project_importer = function(db)
  ---@param p speeddial.lib.project.Project
  return function(p)
    projectdb.add_project(db, p)
  end
end

---@param configs speeddial.lib.source.Source[]
---@param import_cb Importer
M.load_all_sources = function(configs, import_cb)
  for _, cfg in ipairs(configs) do
    M.fetch_source(cfg, import_cb)
  end
end


return M

local normalize = require("speeddial.lib.fs").normalize

---@class speeddial.lib.project.Project
---@field title string: name of this project
---@field root Path|nil: path to project CWD
---@field vcs_root Path|nil: path to project VCS root
---@field source string: source where this project was found
---@field atime integer: last time project was accessed


local M = {}


M._pick_first_dir = function(first, second)
  if first == nil then
    return second
  end
  return first
end

---@param cfg table
---@return speeddial.lib.project.Project
M.new_project = function(cfg)
  local normalize_or_nil = function(s)
    if s == nil then
      return nil
    end
    return normalize(s)
  end

  if cfg.root == nil and cfg.vcs_root == nil then
    error("Either root or vcs_root must be set")
  end

  return {
    title = cfg.title,
    source = cfg.source,
    root = normalize_or_nil(cfg.root),
    vcs_root = normalize_or_nil(cfg.vcs_root),
    atime = cfg.atime or 0
  }
end

---@param project speeddial.lib.project.Project
---@return string
M.as_path = function(project)
  return M.get_project_root(project):absolute()
end

---@param project speeddial.lib.project.Project
---@return Path
M.get_project_root = function(project)
  return M._pick_first_dir(project.root, project.vcs_root)
end

---@param project speeddial.lib.project.Project
---@return Path
M.get_project_vcs_root = function(project)
  return M._pick_first_dir(project.vcs_root, project.root)
end


---@param project speeddial.lib.project.Project
---@param atime integer|nil: optional time to set
M.touch = function(project, atime)
  if atime == nil then
    atime = os.time()
  end
  project.atime = atime
end
---
---@param base speeddial.lib.project.Project
---@param other speeddial.lib.project.Project
M.merge = function(base, other)
  if base.title == nil then
    base.title = other.title
  end
  if base.root == nil then
    base.root = other.root
  elseif other.root ~= nil and base.root:absolute() ~= other.root:absolute() then
    error("Cannot merge projects with different roots!")
  end
  if base.vcs_root == nil then
    base.vcs_root = other.vcs_root
  elseif other.vcs_root ~= nil and base.vcs_root:absolute() ~= other.vcs_root:absolute() then
    error("Cannot merge projects with different vcs_roots!")
  end
  if base.source == nil then
    base.source = other.source
  end
  if other.atime > base.atime then
    base.atime = other.atime
  end
end

return M

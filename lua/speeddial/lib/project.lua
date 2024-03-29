local oop = require("speeddial.oop")
local Path = require("plenary.path")

local fs = require("speeddial.lib.fs")

local M = {}

---@class Project : speeddial.Object
---@operator call : Project
---@field title string
---@field root Path
---@field vcs_root Path
---@field source string
---@field atime integer
local Project = oop.create_class("Project")
M.Project = Project

local extract_root = function(cfg)
  cfg = cfg or {}
  if cfg.root ~= nil then
    return fs.normalize(cfg.root)
  end
  if cfg.vcs_root ~= nil then
    return fs.normalize(cfg.vcs_root)
  end

  return fs.normalize(vim.fn.getcwd())
end

local extract_vcs_root = function(cfg)
  cfg = cfg or {}
  if cfg.vcs_root ~= nil then
    return fs.normalize(cfg.vcs_root)
  end
  error("no vcs root")
end

---@param cfg table|nil
function Project:init(cfg)
  cfg = cfg or {}
  self.title = cfg.title
  self.source = cfg.source or "Unknown"

  self.root = extract_root(cfg)
  self.vcs_root = extract_vcs_root(cfg)

  self.atime = cfg.atime or 0
end

function Project:as_path()
  return self.root:absolute()
end

---@param atime integer|nil
function Project:touch(atime)
  if atime == nil then
    atime = os.time()
  end
  self.atime = atime
end

---@param other Project
function Project:merge(other)
  if self.title == nil then
    self.title = other.title
  end
  if self.root == nil then
    self.root = other.root
  elseif self.root:absolute() ~= other.root:absolute() then
    error("Cannot merge projects with different roots!")
  end
  if self.vcs_root == nil then
    self.vcs_root = other.vcs_root
  elseif self.vcs_root:absolute() ~= other.vcs_root:absolute() then
    error("Cannot merge projects with different vcs_roots!")
  end
  if self.source == nil then
    self.source = other.source
  end
  if other.atime > self.atime then
    self.atime = other.atime
  end
end

return M

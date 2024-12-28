local Path = require("plenary.path")
local M = {}

---@param vcs_root Path: the path to the git repository root
---@return Path: the path to the git config file
function M._git_config_file(vcs_root)
  return vcs_root:joinpath("/.git/config")
end

function M._parse_repo_name_from_url(config_line)
  local s, e = config_line:find("github.com/[^/]+/[^/]+")
  if s then
    local offset = #"github.com/"
    return config_line:sub(s + offset, e)
  end
  return nil
end

function M._parse_remote_name(config_line)
  local s, _, remote = config_line:find('%[remote "(%a+)"%]')
  if s then
    return remote
  end
  return nil
end

---
---@param lines string[]: each line from a .git/config file
---@return table<string,string>: the remotes, and their associated names
function M._parse_git_remotes(lines)
  local remotes = {}
  local last_remote = nil

  local safe_insert = function(name)
    if name == nil then
      return
    end
    remotes["__last"] = name
    if remotes[last_remote] == nil then
      remotes[last_remote] = name
    end
  end

  local safe_remote = function(remote)
    if remote == nil then
      return
    end
    last_remote = remote
  end


  for _, line in pairs(lines) do
    safe_remote(M._parse_remote_name(line))
    safe_insert(M._parse_repo_name_from_url(line))
  end
  return remotes
end

---@param lines string[]: each line from a .git/config file
---@return string: the name of the remote
function M._extract_name_from_git_config(lines)
  local remotes = M._parse_git_remotes(lines)
  return remotes["upstream"] or remotes["origin"] or remotes["__last"]
end

---@param vcs_root Path: the path to the git repository root
---@return string|nil: the common-name of the repo
function M.parse_repo_name_from_git_repo(vcs_root)
  local gitconfig = M._git_config_file(vcs_root)
  local ok, lines = pcall(Path.readlines, gitconfig:absolute())
  if not ok then
    return nil
  end
  return M._extract_name_from_git_config(lines)
end

return M

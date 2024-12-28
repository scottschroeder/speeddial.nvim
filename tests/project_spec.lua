local helpers = require("speeddial.tests.helpers")
local assert = require("luassert")

local eq = helpers.eq

describe("speeddial.lib.project", function()
  local project = require("speeddial.lib.project")
  describe("get roots", function()
    it("can not create project without root or vcs_root", function()
      local ok, p = pcall(project.new_project, nil)
      eq(false, ok)

      local ok, p = pcall(project.new_project, { root = "/foo" })
      eq(true, ok)
      eq("/foo", project.as_path(p))

      local ok, p = pcall(project.new_project, { vcs_root = "/foo" })
      eq(true, ok)
      eq("/foo", project.as_path(p))
    end)

    it("no directory is nil", function()
      local p = {}
      eq(project.get_project_root(p), nil)
    end)

    it("pick root if available", function()
      local p = {
        root = "a",
        vcs_root = "b",
      }
      eq("a", project.get_project_root(p))
    end)

    it("pick vcs_root if no root", function()
      local p = {
        root = nil,
        vcs_root = "b",
      }
      eq("b", project.get_project_root(p))
    end)

    it("pick vcs_root if available", function()
      local p = {
        root = "a",
        vcs_root = "b",
      }
      eq("b", project.get_project_vcs_root(p))
    end)

    it("pick root if no vcs_root", function()
      local p = {
        root = "a",
        vcs_root = nil,
      }
      eq("a", project.get_project_vcs_root(p))
    end)
  end)

  describe("update atime", function()
    it("set time manually", function()
      local p = project.new_project({ root = "/x" })
      eq(0, p.atime)
      project.touch(p, 1)
      eq(1, p.atime)
    end)

    it("set time automatically", function()
      local p = project.new_project({ root = "/x" })
      eq(0, p.atime)
      local expected = os.time()
      project.touch(p)
      local diff = p.atime - expected
      assert.is_true(diff < 2)
    end)
  end)

  describe("merge", function()
    local create_and_merge = function(a, b)
      local pa = project.new_project(a)
      local pb = project.new_project(b)
      project.merge(pa, pb)
      return pa
    end

    it("keep source", function()
      local p = create_and_merge({ root = "/foo", source = "r" }, { root = "/foo", source = "s" })
      eq("r", p.source)
    end)

    it("inherit source", function()
      local p = create_and_merge({ root = "/foo" }, { root = "/foo", source = "s" })
      eq("s", p.source)
    end)

    it("get newer atime", function()
      local p = create_and_merge({ root = "/foo", atime = 1 }, { root = "/foo", atime = 2 })
      eq(2, p.atime)
    end)

    it("keep newer atime", function()
      local p = create_and_merge({ root = "/foo", atime = 3 }, { root = "/foo", atime = 2 })
      eq(3, p.atime)
    end)

    it("root and vcs_root merge", function()
      local p = create_and_merge({ root = "/foo/bar" }, { vcs_root = "/foo" })
      eq("/foo/bar", p.root:absolute())
      eq("/foo", p.vcs_root:absolute())
    end)
  end)
end)

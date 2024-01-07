local helpers = require("speeddial.tests.helpers")

local eq, neq = helpers.eq, helpers.neq

describe("speeddial.lib.project", function()
  local Project = require("speeddial.lib.project").Project


  describe("Project", function()
    it("it can be created", function()
      local p1 = Project({ vcs_root = "foo" })
      local p2 = Project({ vcs_root = "foo" })

      eq(p1, p2)
    end)

    it("different objects are different", function()
      local p1 = Project({ vcs_root = "foo" })
      local p2 = Project({ vcs_root = "bar" })

      neq(p1, p2)
    end)

    it("can be turned into a path", function()
      local p1 = Project({ root = "/foo/bar/../baz", vcs_root = "foo" })
      local aspath = p1:as_path()
      eq(aspath, "/foo/baz")
    end)

    it("default time is zero", function()
      local p1 = Project({ vcs_root = "foo" })
      eq(p1.atime, 0)
    end)

    it("touch is after zero", function()
      local p1 = Project({ vcs_root = "foo" })
      p1:touch(nil)
      assert(p1.atime > 0)
    end)

    it("touch set a specific time", function()
      local p1 = Project({ vcs_root = "foo" })
      p1:touch(4)
      eq(p1.atime, 4)
    end)
  end)
end)

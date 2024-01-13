local helpers = require("speeddial.tests.helpers")

local eq, neq = helpers.eq, helpers.neq

describe("speeddial.lib.projectdb", function()
  local Project = require("speeddial.lib.project").Project
  local ProjectDB = require("speeddial.lib.projectdb").ProjectDB


  describe("ProjectDB", function()
    it("starts empty", function()
      local db = ProjectDB()
      eq(0, db:len())
    end)

    it("counts objects", function()
      local db = ProjectDB()
      db:add(Project({ vcs_root = "foo" }))
      eq(1, db:len())
      db:add(Project({ vcs_root = "bar" }))
      eq(2, db:len())
    end)

    it("merges items", function()
      local db = ProjectDB()
      db:add(Project({ title = "first", vcs_root = "foo", atime = 10 }))
      db:add(Project({ title = "second", vcs_root = "foo", atime = 20 }))
      db:add(Project({ title = "third", vcs_root = "foo", atime = 5 }))

      eq(1, db:len())
      for _, v in pairs(db:projects()) do
        eq("first", v.title)
        eq(20, v.atime)
      end
    end)
  end)
end)

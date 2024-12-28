local helpers = require("speeddial.tests.helpers")
local Path = require("plenary.path")
local projectdb = require("speeddial.lib.projectdb")
local project = require("speeddial.lib.project")

local eq, neq = helpers.eq, helpers.neq

describe("speeddial.lib.projectdb", function()
  local normalize = require("speeddial.lib.fs").normalize
  describe("state_file_path", function()
    local create_project_for_state_dir = function(opts)
      local db = projectdb.create_db(opts)
      return db.state_file
    end

    it("empty string is null", function()
      eq(nil, create_project_for_state_dir({ state_file = "" }))
    end)

    it("abs path is exact", function()
      eq(Path:new("/path/to/state.json"), create_project_for_state_dir({ state_file = "/path/to/state.json" }))
    end)

    it("rel path", function()
      eq(normalize("foo.json"), create_project_for_state_dir({ state_file = "foo.json" }))
    end)

    it("default path uses data dir", function()
      local data_dir = vim.api.nvim_call_function('stdpath', { 'data' })
      eq(Path:new(data_dir .. "/speeddial_project_db.json"), create_project_for_state_dir())
    end)
  end)
  describe("db creation", function()
    it("new db is empty", function()
      local db = projectdb.create_db()
      eq({}, db.projects)
      eq(0, projectdb.len(db))
    end)
  end)

  describe("db insert", function()
    it("insert into empty db", function()
      local db = projectdb.create_db()
      projectdb.add_project(db, project.new_project({ title = "foo", root = "/foo" }))
      eq(1, projectdb.len(db))
      eq("foo", db.projects["/foo"].title)
    end)

    it("insert two projects", function()
      local db = projectdb.create_db()
      projectdb.add_project(db, project.new_project({ title = "foo", root = "/foo" }))
      projectdb.add_project(db, project.new_project({ title = "bar", root = "/bar" }))
      eq(2, projectdb.len(db))
    end)

    it("insert and update project", function()
      local db = projectdb.create_db()
      projectdb.add_project(db, project.new_project({ title = "foo", root = "/foo" }))
      eq(1, projectdb.len(db))
      eq(nil, db.projects["/foo"].source)
      projectdb.add_project(db, project.new_project({ title = "foo", root = "/foo", source = "git" }))
      eq(1, projectdb.len(db))
      eq("git", db.projects["/foo"].source)
    end)
  end)
end)

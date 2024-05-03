local M = {}

-- Shows the results from the search in a Telescope picker.
function M.show(results)
  M.results = results
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local pickers = require 'telescope.pickers'
  local actions_state = require 'telescope.actions.state'
  local actions = require 'telescope.actions'
  local entry_display = require 'telescope.pickers.entry_display'

  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = 2 },
      { width = 0.95 },
    },
  }

  local title = 'Virtual environments'

  local finder = finders.new_table {
    results = M.results,
    entry_maker = function(entry)
      entry.value = entry.path
      entry.ordinal = entry.path
      entry.display = function(e)
        return displayer {
          { e.icon },
          { e.path },
        }
      end

      return entry
    end,
  }

  local venv = require 'venv-selector.venv'
  local opts = {
    prompt_title = title,
    finder = finder,
    -- results_title = title,
    layout_strategy = 'horizontal',
    layout_config = {
      height = 0.6,
      width = 140,
      prompt_position = 'top',
    },
    cwd = require('telescope.utils').buffer_dir(),
    sorting_strategy = 'ascending',
    sorter = conf.file_sorter {},
    attach_mappings = function(bufnr, map)
      map('i', '<cr>', function()
        --venv.activate_venv()
        actions.close(bufnr)
      end)

      map('i', '<C-r>', function()
        --M.remove_results()
        local picker = actions_state.get_current_picker(bufnr)
        -- Delay by 10ms to achieve the refresh animation.
        picker:refresh(finder, { reset_prompt = true })
        vim.defer_fn(function()
          --venv.load { force_refresh = true }
        end, 10)
      end)

      return true
    end,
  }
  pickers.new({}, opts):find()

  --venv.load()
  -- venv.load must be called after the picker is displayed; otherwise, Vim will not be able to get the correct bufnr.
end

return M
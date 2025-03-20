return {
  'nvim-neotest/neotest',
  event = 'VeryLazy',
  dependencies = {
    'nvim-neotest/neotest-go',
    'nvim-neotest/neotest-python',
    --"rcasia/neotest-java",
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  requires = {
    'nvim-neotest/neotest-go',
    'nvim-neotest/neotest-python',
    -- Your other test adapters here
  },
  config = function()
    -- get neotest namespace (api call creates or returns namespace)
    local neotest_ns = vim.api.nvim_create_namespace 'neotest'
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
          return message
        end,
      },
    }, neotest_ns)
    require('neotest').setup {
      -- your neotest config here
      adapters = {
        require 'neotest-go',
        require 'neotest-python',
      },
    }
    -- Mapping
    -- Test Near
    vim.keymap.set('n', '<leader>tn', function()
      require('neotest').run.run()
    end, {})
    -- Test All
    vim.keymap.set('n', '<leader>ta', function()
      require('neotest').run.run(vim.fn.expand '%')
    end, {})
    -- Test summary toggle
    vim.keymap.set('n', '<leader>ts', function()
      require('neotest').summary.toggle()
    end, {})
    -- Test Info
    vim.keymap.set('n', '<leader>ti', function()
      require('neotest').output.open { enter = true }
    end, {})
  end,
}

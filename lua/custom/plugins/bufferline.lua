return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {
      options = {
        --mode = "tabs",
        offsets = { { filetype = 'neo-tree', text = 'File Explorer', separator = true, text_align = 'left' } },
        custom_filter = function(buf_number)
          -- Oculta los buffers de terminal
          local buf_name = vim.api.nvim_buf_get_name(buf_number)
          if vim.bo[buf_number].buftype == 'terminal' then
            return false
          end
          return true
        end,
      },
    }
    --  Para moverse entre buffers (bufferline)
    vim.keymap.set('n', '<Tab>', '<cmd>bn<CR>', { noremap = true })
    vim.keymap.set('n', '<S-Tab>', '<cmd>bp<CR>', { noremap = true })
  end,
}

------------------------------------------------------------------
--- Plantilla para archivos .py con la funcion main lista
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.py',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false,
      { 'def main():', '    pass', '', 'if __name__ == "__main__":', '    main()' })
    vim.api.nvim_win_set_cursor(0, { 2, 4 }) -- Mueve el cursor a la línea con la indentación
  end,
})

------------------------------------------------------------------
-- Plantille para archivos ansi C
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.c',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, {
      '#include <stdio.h>',
      '',
      'int main()',
      '{',
      '    return 0;',
      '}',
    })
    vim.api.nvim_win_set_cursor(0, { 4, 4 }) -- Coloca el cursor dentro de main()
  end,
})

------------------------------------------------------------------
-- compilar y ejecutar
vim.keymap.set('n', '<leader>ex', function()
  local file_name = vim.api.nvim_buf_get_name(0)
  local file_type = vim.bo.filetype

  -- Función para abrir una terminal flotante limpia
  local function open_terminal(cmd)
    vim.cmd('botright 10split | terminal ' .. cmd)
  end

  if file_type == 'lua' then
    open_terminal('lua ' .. file_name)
  elseif file_type == 'c' then
    local compile_cmd = 'gcc ' .. file_name .. ' -o /tmp/a.out && /tmp/a.out'
    open_terminal(compile_cmd)
  elseif file_type == 'python' then
    open_terminal('python3 ' .. file_name)
  else
    print 'Formato no soportado'
  end
end)

------------------------------------------------------------------
-- Trucos para el modo terminal
---- Sin numeros en modo terminal
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.cmd.startinsert()
  end,
})

------------------------------------------------------------------
---- Small terminal
vim.keymap.set('n', '<space>st', function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd 'J'
  vim.cmd.startinsert()
  vim.api.nvim_win_set_height(0, 5)
end, { desc = 'Open small terminal' })

------------------------------------------------------------------
-- Numeros de linea
---- Absoluto/relativo para line numbers
vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
  pattern = '*',
  callback = function()
    vim.wo.relativenumber = false
    vim.wo.number = true
  end,
})

vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  pattern = '*',
  callback = function()
    vim.wo.relativenumber = true
    vim.wo.number = true
  end,
})

------------------------------------------------------------------
-- Recuerda donde estaba al salir del archivo
-- y lo abre en esa posición
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  callback = function()
    local row, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
    if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, { row, col })
    end
  end,
})

------------------------------------------------------------------

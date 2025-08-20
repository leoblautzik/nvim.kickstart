------------------------------------------------------------------
--- Plantilla para archivos .py con la funcion main lista
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.py',
  callback = function()
    local filename = vim.fn.expand '%:t'
    -- Evita que corra en archivos de test
    if filename:match '^test_' or filename:match '_test%.py$' then
      return
    end

    vim.api.nvim_buf_set_lines(0, 0, 0, false, {
      'def main():',
      '    pass',
      '',
      'if __name__ == "__main__":',
      '    main()',
    })
    vim.api.nvim_win_set_cursor(0, { 2, 4 })
  end,
})

-- para los archivos de test_.py
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = { 'test_*.py', '*_test.py' },
  callback = function()
    local filepath = vim.fn.expand '%:p'
    local relative = filepath:gsub(vim.fn.getcwd() .. '/', '')
    local parts = vim.split(relative, '/')

    local dir = parts[#parts - 1] or ''
    local file = parts[#parts] or ''

    file = file:gsub('%.py$', '')
    file = file:gsub('^test_', ''):gsub('_test$', '')

    local function to_camel(s)
      local res = {}
      for word in string.gmatch(s, '[^_]+') do
        table.insert(res, word:sub(1, 1):upper() .. word:sub(2))
      end
      return table.concat(res)
    end

    local class_name = 'Test' .. to_camel(dir) .. to_camel(file)

    vim.api.nvim_buf_set_lines(0, 0, 0, false, {
      'import unittest',
      '',
      'class ' .. class_name .. '(unittest.TestCase):',
      '    def test_example(self):',
      '        self.assertEqual(1 + 1, 2)',
      '',
      "if __name__ == '__main__':",
      '    unittest.main()',
    })

    vim.api.nvim_win_set_cursor(0, { 4, 8 })
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
-- Guarda el archivo si está modificado
-- Reutiliza una terminal si ya existe
-- Envia el nuevo comando a esa terminal
-- Funciona para C, Python, Go, Lua
-- Muestra errores de compilación en quickfix si es C
-- Ejecutar código según tipo de archivo, abre panel único de salida

vim.keymap.set('n', '<leader>ex', function()
  if vim.bo.modified then
    vim.cmd 'write'
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  local file_type = vim.bo.filetype

  local function run_cmd_output(cmd, cwd)
    -- Cerrar panel anterior si existe
    if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
      vim.api.nvim_win_close(vim.g.runner_win, true)
    end

    -- Crear nuevo buffer temporal para la terminal
    local buf = vim.api.nvim_create_buf(false, true)
    local win_height = 12
    vim.cmd('botright ' .. win_height .. 'split')
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    vim.g.runner_win = win

    -- Ejecutar comando
    vim.fn.termopen(cmd, {
      cwd = cwd, -- directorio de trabajo opcional
      on_exit = function()
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
      end,
    })
  end

  if file_type == 'lua' then
    run_cmd_output({ 'lua', file_name }, vim.fn.expand '%:p:h')
  elseif file_type == 'c' then
    local out = '/tmp/a.out'
    local compile_cmd = { 'gcc', file_name, '-o', out }
    local compile_result = vim.fn.system(compile_cmd)
    if vim.v.shell_error ~= 0 then
      print('Error de compilación:\n' .. compile_result)
    else
      run_cmd_output({ out }, vim.fn.expand '%:p:h')
    end
  elseif file_type == 'python' then
    run_cmd_output({ 'python3', file_name }, vim.fn.expand '%:p:h')
  elseif file_type == 'go' then
    -- Buscar go.mod, si existe usar su carpeta, si no la del archivo
    local gomod = vim.fn.findfile('go.mod', vim.fn.expand '%:p:h' .. ';')
    local dir = gomod ~= '' and vim.fn.fnamemodify(gomod, ':h') or vim.fn.expand '%:p:h'
    run_cmd_output({ 'go', 'run', file_name }, dir)
  else
    print 'Formato no soportado'
  end
end, { desc = 'Ejecutar archivo según su tipo (Go, C, Python, Lua, etc.)' })

-- Cerrar panel de ejecución con <leader>ec
vim.keymap.set('n', '<leader>ec', function()
  if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
    vim.api.nvim_win_close(vim.g.runner_win, true)
    vim.g.runner_win = nil
  else
    print 'No hay panel de ejecución activo'
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

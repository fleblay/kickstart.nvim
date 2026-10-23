-- Git commands and status window
vim.pack.add { 'https://github.com/tpope/vim-fugitive' }

require('which-key').add {
  { '<leader>g', group = '[G]it' },
}

vim.keymap.set('n', '<leader>gs', function()
  if vim.bo.filetype ~= 'fugitive' then
    vim.cmd 'G'
  else
    -- :close (not :q) so a lone status window never quits Neovim
    pcall(vim.cmd, 'close')
  end
end, { desc = 'Toggle [G]it [S]tatus' })

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('custom-fugitive', { clear = true }),
  pattern = 'fugitive',
  callback = function() vim.keymap.set('n', '<leader>gp', '<Cmd>Git push<CR>', { buffer = true, desc = '[G]it [P]ush' }) end,
})

-- vim: ts=2 sts=2 sw=2 et

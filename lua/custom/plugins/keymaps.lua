-- [[ Personal Keymaps ]]

-- Remove s as it is the same as 'cl' (frees the s prefix for the maps below)
vim.keymap.set('n', 's', '<Nop>')

-- Move by display lines unless a count is given
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Quickfix list navigation
vim.keymap.set('n', 'sqn', '<Cmd>cn<CR>', { desc = 'Go to next quickfix list item' })
vim.keymap.set('n', 'sqp', '<Cmd>cp<CR>', { desc = 'Go to previous quickfix list item' })
vim.keymap.set('n', 'sqg', '<Cmd>.cc<CR>', { desc = 'Go to current quickfix list item' })
vim.keymap.set('n', 'sqo', '<Cmd>copen<CR>', { desc = 'Open quickfix list' })
vim.keymap.set('n', 'sqc', '<Cmd>cclose<CR>', { desc = 'Close quickfix list' })

-- Write all files
vim.keymap.set('n', 'sw', '<Cmd>wa<CR>', { desc = 'Write all files' })

-- vim: ts=2 sts=2 sw=2 et

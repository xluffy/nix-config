vim.api.nvim_create_autocmd("FileType", {
  pattern = "gohtmltmpl",
  callback = function() vim.treesitter.start(0, "gotmpl") end,
})

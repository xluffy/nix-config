return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = {
      highlight = true,
      indent = true,
      auto_install = true,
      ensure_installed = {
        "lua",
        "vim",
        "html",
        "go",
        "gotmpl",
      },
    },
  },
}

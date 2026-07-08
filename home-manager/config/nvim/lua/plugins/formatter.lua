return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      html = { "prettier" },
    },
    formatters = {
      prettier = {
        prepend_args = {
          "--tab-width",
          "2",
          "--use-tabs",
          "false",
        },
      },
    },
  },
}

-- nvim-treesitter query_predicates.lua:141 passes invalid nodes to get_node_text
-- in nvim 0.12+ due to TSNode API change. Wrap to catch and suppress.
local _orig_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
  local ok, result = pcall(_orig_get_node_text, node, source, opts)
  return ok and result or ""
end

require("griffithai")
vim.cmd("Copilot disable")

function ToggleCopilot()
    status = vim.fn["copilot#Enabled"]()
    if status == 1 then
        vim.cmd("Copilot disable")
    elseif status == 0 then
    	vim.cmd("Copilot enable")
    end
    vim.cmd("Copilot status")
end


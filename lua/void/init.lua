local M = {}

local last_activity_timestamp = os.time()
local is_inactive = false

function M.start_timer()
    is_inactive = false
end

function M.setup(opts)
    last_activity_timestamp = os.time()

    local function set_default(opt, default)
        local prefix = "void_"
        if vim.g[prefix .. opt] ~= nil then
            return
        elseif opts[opt] ~= nil then
            vim.g[prefix .. opt] = opts[opt]
        else
            vim.g[prefix .. opt] = default
        end
    end

    set_default("inactivity_threshold_in_min", 2)
    set_default("inactivity_check_freq_in_sec", 1)

    vim.api.nvim_exec([[
          augroup Void
            autocmd!

            autocmd BufEnter * lua require('void').start_timer()
            autocmd BufLeave,QuitPre * lua require('void').stop_timer()

            autocmd TextChanged,TextChangedI * lua require('void').activity_on_keystroke()
            autocmd CursorMoved,CursorMovedI * lua require('void').activity_on_keystroke()
          augroup END
    ]], false)

    local timer = vim.loop.new_timer()
    timer:start(0,
        vim.g.void_inactivity_check_freq_in_sec * 1000,
        vim.schedule_wrap(function()
            handle_inactivity()
        end)
    )
end

return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
		}

		-- 🔧 Always use a global fallback ESLint config
		-- (or project-specific one if it exists)
		local function get_eslint_config()
			local cwd = vim.fn.getcwd()
			local local_config = cwd .. "/.eslintrc.json"
			if vim.fn.filereadable(local_config) == 1 then
				return local_config
			end
			local local_js = cwd .. "/.eslintrc.js"
			if vim.fn.filereadable(local_js) == 1 then
				return local_js
			end
			return vim.fn.expand("~/.config/eslint/.eslintrc.json")
		end

		-- Ensure eslint_d uses the chosen config file
		local eslint = lint.linters.eslint_d
		if eslint then
			eslint.args = {
				"--config",
				get_eslint_config(),
				"--stdin",
				"--stdin-filename",
				function()
					return vim.api.nvim_buf_get_name(0)
				end,
				"--format",
				"json",
			}
		end

		-- Auto-run linting on write or insert leave
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		-- Manual trigger
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}

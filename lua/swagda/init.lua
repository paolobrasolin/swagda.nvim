local lpeg = require("lpeg")
local P, R, S, V, C = lpeg.P, lpeg.R, lpeg.S, lpeg.V, lpeg.C

local function mknode(type)
	return function(...)
		return { type = type, ... }
	end
end

local grammar = P({
	"Root",
	Root = V("Expr") * -1,

	Expr = V("Composition") + V("ExprNoComp"),
	ExprNoComp = V("Application") + V("ParenExpr") + V("QId"),
	ParenExpr = P("(") * V("Space") * V("Expr") * V("Space") * P(")") / mknode("par"),

	Composition = V("ExprNoComp") * (V("Space") * V("QOp") * V("Space") * V("ExprNoComp")) ^ 1 / mknode("com"),
	Application = V("QId") * V("Space") * (V("ParenExpr") + V("Application") + V("QId")) / mknode("app"),

	QOp = C((V("Id") * P(".")) ^ 0 * V("Op")) / mknode("op"),
	QId = C((V("Id") * P(".")) ^ 0 * V("Id")) / mknode("id"),

	Op = P("∘"),
	Id = (R("az", "AZ") + P("1") + P("_") + P("ϵ") + P("η") + P("₁") + P("₀")) ^ 1,

	Space = S(" \t\n") ^ 0,
})

local function parse(str)
	return grammar:match(str)
end

local function unparse(ast)
	if ast.type == "com" then
		local result = {}
		for i = 1, #ast, 2 do
			table.insert(result, unparse(ast[i]))
			if i < #ast then -- If there's an operator and next expression
				table.insert(result, " " .. unparse(ast[i + 1]) .. " ")
			end
		end
		return table.concat(result)
	elseif ast.type == "app" then
		return unparse(ast[1]) .. " " .. unparse(ast[2])
	elseif ast.type == "par" then
		return "(" .. unparse(ast[1]) .. ")"
	elseif ast.type == "id" or ast.type == "op" then
		return ast[1]
	else
		error("Unknown node type: " .. tostring(ast.type))
	end
end

local function distribute(ast)
	if not ast or type(ast) ~= "table" then
		return ast
	end

	local handlers = {
		par = function(node)
			node[1] = distribute(node[1])
			return node
		end,

		app = function(node)
			node[2] = distribute(node[2])

			local arg = node[2]
			local comNode = arg.type == "par" and arg[1].type == "com" and arg[1]

			if not comNode then
				return node
			end

			local result = { type = "com" }
			for _, term in ipairs(comNode) do
				if term.type == "op" then
					table.insert(result, term)
				elseif term.type == "par" then
					table.insert(result, {
						type = "par",
						distribute({
							type = "app",
							[1] = node[1], -- NOTE: you *might* need a deepcopy
							[2] = term,
						}),
					})
				else
					table.insert(result, {
						type = "par",
						distribute({
							type = "app",
							[1] = node[1], -- NOTE: you *might* need a deepcopy
							[2] = { type = "par", term },
						}),
					})
				end
			end
			return result
		end,

		com = function(node)
			local result = { type = "com" }
			for _, child in ipairs(node) do
				table.insert(result, distribute(child))
			end
			return result
		end,

		id = function(node)
			return node
		end,
	}

	return (handlers[ast.type] or function(node)
		return node
	end)(ast)
end

local function simplify(str)
	return unparse(distribute(parse(str)))
end

local function humanize(str)
	local out = str
	out = out:gsub(".F₀", "")
	out = out:gsub(".F₁", "")
	out = out:gsub("%f[%a][%a.]+%.id", "1")
	out = out:gsub("%f[%a][%a.]+%.∘", "∘")
	return out
end

local function minifize(str)
	local out = str
	out = out:gsub("[() ]", "")
	local parts = vim.split(out, "∘")
	local filtered = vim.tbl_filter(function(part)
		return not part:match("1$")
	end, parts)
	return table.concat(filtered, " ∘ ")
end

local function tidytidy(str)
	return minifize(humanize(simplify(str)))
end

local function apply_to_selection(transformation)
	-- FIXME: this acts wonky when selecting a line with V
	local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	local source_lines = vim.api.nvim_buf_get_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, {})
	local target_lines = vim.split(transformation(table.concat(source_lines, "\n")), "\n")
	vim.api.nvim_buf_set_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, target_lines)
end

local function setup()
	vim.api.nvim_create_user_command("SwagdaSimplifySelection", function()
		apply_to_selection(simplify)
	end, { range = true })
	vim.api.nvim_create_user_command("SwagdaHumanizeSelection", function()
		apply_to_selection(humanize)
	end, { range = true })
	vim.api.nvim_create_user_command("SwagdaMinifizeSelection", function()
		apply_to_selection(minifize)
	end, { range = true })
	vim.api.nvim_create_user_command("SwagdaTidytidySelection", function()
		apply_to_selection(tidytidy)
	end, { range = true })
end

return {
	setup = setup,
	apply_to_selection = apply_to_selection,
	parse = parse,
	unparse = unparse,
	distribute = distribute,
	simplify = simplify,
	humanize = humanize,
	minifize = minifize,
}

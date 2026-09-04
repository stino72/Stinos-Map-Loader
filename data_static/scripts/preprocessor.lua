---@param flag string
---@param flags string[]
---@return boolean
local function has_flag(flag, flags)
	for index, f in ipairs(flags) do
		if flag == f then
			return true
		end
	end
	return false
end


---@param lua_file string
---@param flags string[]
---@return string
function ResolveMarcos(lua_file, flags)
	---@type string
	local file = "--Export Flags:\n"

	for index, flag in ipairs(flags) do
		file = file .. "-- " .. flag .. "\n"
	end

	---@type integer?
	local pos = -1

	while pos != nil do
		local start
		local flag_end
		local flag
		local tmp

		start, pos = string.find(lua_file, "\n--%[", pos + 1)

		if pos == nil or start == nil then
			goto continue;
		end

		flag_end, pos = string.find(lua_file, "]~\n", pos + 1)
		if pos == nil or flag_end == nil then
			goto continue;
		end

		flag = string.sub(lua_file, start + 2, flag_end - 1)

		tmp, pos = string.find(lua_file, "\n--END\n", pos + 1)
		if tmp == nil or pos == nil then
			goto continue
		end

		if not has_flag(flag, flags) then
			lua_file = string.sub(lua_file, 0, start - 2) .. string.sub(lua_file, pos + 1, lua_file:len())
			pos = -1
		end
	    ::continue::
	end

	pos = -1
	while pos != nil do
		local start
		local flag_end
		local flag
		local tmp

		start, pos = string.find(lua_file, "\n--!%[", pos + 1)

		if pos == nil or start == nil then
			goto continue;
		end

		flag_end, pos = string.find(lua_file, "]~\n", pos + 1)
		if pos == nil or flag_end == nil then
			goto continue;
		end

		flag = string.sub(lua_file, start + 3, flag_end - 1)

		tmp, pos = string.find(lua_file, "\n--END\n", pos + 1)
		if tmp == nil or pos == nil then
			goto continue
		end

		if has_flag(flag, flags) then
			lua_file = string.sub(lua_file, 0, start - 2) .. string.sub(lua_file, pos + 1, lua_file:len())
			pos = -1
		end
	    ::continue::
	end

	file = string.gsub(file .. "\n" .. lua_file, "\n\n\n", "\n\n")

	return file
end

---@param lua_file string
---@param var string
---@param value any
---@return string
function SetVariable(lua_file, var, value)
	local s, e = string.find(lua_file, var .. " = ")
	if s == nil or e == nil then
		return lua_file
	end
	local new_line = string.find(lua_file, "\n", e + 1)
	if new_line == nil then
		return lua_file
	end

	return string.sub(lua_file, 0, e) .. value .. string.sub(lua_file, new_line, lua_file:len())
end

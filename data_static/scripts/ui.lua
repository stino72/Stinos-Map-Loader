---@class ToggleCallbackData
---@field playerId PlayerID
---@field id UIElementID
---@field type string
---@field value string
---@field state boolean
---@field data any
local ToggleCallbackData = {}
ToggleCallbackData.__index = ToggleCallbackData

---@class ToggleButtonData
---@field text string
---@field callback fun(data: ToggleCallbackData)
---@field data any?
local ToggleButtonData = {}
ToggleButtonData.__index = ToggleButtonData

---@param state boolean
---@return string
function GetToggleString(state)
	if state then
		return " [<color=green>True</color>]"
	else
		return " [<color=red>False</color>]"
	end
end

---@param playerid PlayerID
---@param id string
---@param text string
---@param defaultState boolean
---@param onPressedCallback fun(data: ToggleCallbackData)
---@param data any?
function AddToggleButton(playerid, id, text, defaultState, onPressedCallback, data)
	---@type ToggleButtonData
	local buttonData = {
		text = text,
		callback = onPressedCallback,
		data = data,
	}

	tm.playerUI.AddUIButton(playerid, id, text .. GetToggleString(defaultState), OnToggleButtonPressed, buttonData)
end

---@param data UICallbackData
function OnToggleButtonPressed(data)
	---@type ToggleButtonData
	local buttonData = data.data

	local newState = string.find(data.value, " [<color=green>True</color>]", 0, true) == nil
	tm.playerUI.SetUIValue(data.playerId, data.id, buttonData.text .. GetToggleString(newState))

	---@type ToggleCallbackData
	local callbackData = {
		playerId = data.playerId,
		id = data.id,
		type = data.type,
		value = buttonData.text,
		state = newState,
		data = buttonData.data,
	}
	buttonData.callback(callbackData);
end

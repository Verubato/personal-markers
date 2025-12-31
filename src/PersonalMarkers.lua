if not C_NamePlate or not C_NamePlate.GetNamePlates or not C_NamePlate.GetNamePlateForUnit then
	print("PersonalMarkers is unable to run due to missing nameplate APIs.")
	return
end

local iconPath = "Interface\\AddOns\\PersonalMarkers\\Media\\"
local iconList = {
	[1] = {
		filename = "Aura10.tga",
		colour = { 1, 1, 1 },
	},
	[2] = {
		filename = "Aura29.tga",
		colour = { 0.8, 0.2, 0.2 },
	},
	[3] = {
		filename = "Aura12.tga",
		colour = { 0, 1, 1 },
	},
	[4] = {
		filename = "Aura14.tga",
		colour = { 0.8, 0.8, 0.8 },
	},
	[5] = {
		filename = "Aura25.tga",
		colour = { 0.2, 0.9, 0.2 },
	},
	[6] = {
		filename = "Aura9.tga",
		colour = { 0.6, 0.2, 0.8 },
	},
	[7] = {
		filename = "Aura13.tga",
		colour = { 1, 0.5, 0 },
	},
	[8] = {
		filename = "Aura27.tga",
		colour = { 1, 1, 0 },
	},
}
local width = 50
local height = 50
local marks = {}

local function GetOrCreateMarker(unitFrame)
	local marker = unitFrame.PersonalMarker

	if marker then
		return marker
	end

	marker = unitFrame:CreateTexture(nil, "OVERLAY", nil, 7)
	marker:SetDesaturated(true)
	marker:Hide()

	unitFrame.PersonalMarker = marker
	return marker
end

local function Mark(unit, number)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit or "target")

	if not nameplate or not nameplate.UnitFrame then
		return
	end

	if number < 1 or number > #iconList then
		return
	end

	local marker = GetOrCreateMarker(nameplate.UnitFrame)

	local icon = iconList[number]

	if not icon then
		return
	end

	marker:ClearAllPoints()
	marker:SetPoint("CENTER", nameplate.UnitFrame, "TOP", 0, 10)

	local file = iconPath .. icon.filename
	marker:SetTexture(file)
	marker:SetSize(width, height)

	local c = icon.colour
	marker:SetVertexColor(c[1], c[2], c[3], 1)
	marker:Show()

	-- hide the existing marker if exists
	local existing = marks[number]

	if existing and existing.UnitFrame and existing.UnitFrame.PersonalMarker then
		existing.UnitFrame.PersonalMarker:Hide()
	end

	marks[number] = nameplate
end

local function Unmark(unit)
	local targetNameplate = C_NamePlate.GetNamePlateForUnit(unit or "target")

	if not targetNameplate then
		return
	end

	if not targetNameplate.UnitFrame then
		return
	end

	if not targetNameplate.UnitFrame.PersonalMarker then
		return
	end

	targetNameplate.UnitFrame.PersonalMarker:Hide()
end

local function UnmarkAll()
	for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
		if nameplate.UnitFrame and nameplate.UnitFrame.PersonalMarker then
			nameplate.UnitFrame.PersonalMarker:Hide()
		end
	end
end

local function PrintUsage()
	print("Usage: /mark [unit] [1-8]")
end

local function Load()
	SlashCmdList.MARK = function(argString)
		if not argString or argString == "" then
			PrintUsage()
			return
		end

		local args = {}

		for word in string.gmatch(argString or "", "%S+") do
			args[#args + 1] = word
		end

		if #args == 1 then
			local number = tonumber(args[1])

			if number then
				Mark("target", number)
				return
			end
		end

		if #args == 2 then
			local unit = tostring(args[1])
			local number = tonumber(args[2])

			if unit and number then
				Mark(unit, number)
			end

			return
		end

		PrintUsage()
	end

	SlashCmdList.UNMARK = function(arg)
		if arg == "all" then
			UnmarkAll()
			return
		end

		local unit = tostring(arg)

		Unmark(unit)
	end

	SLASH_MARK1 = "/mark"
	SLASH_UNMARK1 = "/unmark"
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", Load)

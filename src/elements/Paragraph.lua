local Creator = require("../modules/Creator")
local New = Creator.New
local Element = {}
local CreateButton = require("../components/ui/Button").New

function Element:New(ElementConfig)
	ElementConfig.Hover = false
	ElementConfig.TextOffset = 0
	ElementConfig.ParentConfig = ElementConfig
	ElementConfig.IsButtons = ElementConfig.Buttons and #ElementConfig.Buttons > 0 and true or false

	local ParagraphModule = {
		__type = "Paragraph",
		Title = ElementConfig.Title or "Paragraph",
		Desc = ElementConfig.Desc or nil,
		Locked = ElementConfig.Locked or false,
	}

	local Paragraph = require("../components/window/Element")(ElementConfig)
	ParagraphModule.ParagraphFrame = Paragraph

	if ElementConfig.ViewportModel then
		local vpHeight = ElementConfig.ViewportHeight or 120

		local ViewportFrame = New("ViewportFrame", {
			Size = UDim2.new(1, 0, 0, vpHeight),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = Paragraph.UIElements.Container,
			LayoutOrder = -1,
		})

		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = ViewportFrame,
		})

		local ok, cloned = pcall(function()
			return ElementConfig.ViewportModel:Clone()
		end)

		if ok and cloned then
			cloned.Parent = ViewportFrame

			local cam = Instance.new("Camera")
			cam.CameraType = Enum.CameraType.Fixed
			cam.FieldOfView = ElementConfig.ViewportFOV or 65

			local pivot = ElementConfig.ViewportModel:GetPivot().Position
			local offset = ElementConfig.ViewportOffset or Vector3.new(0, 2, 5)
			cam.CFrame = CFrame.new(pivot + offset, pivot)

			cam.Parent = ViewportFrame
			ViewportFrame.CurrentCamera = cam
		end

		ParagraphModule.ViewportFrame = ViewportFrame
		
		function ParagraphModule:SetModel(newModel, newOffset)
			for _, ch in ipairs(ViewportFrame:GetChildren()) do
				if not ch:IsA("Camera") and not ch:IsA("UICorner") then
					ch:Destroy()
				end
			end

			if newModel then
				local ok2, cloned2 = pcall(function() return newModel:Clone() end)
				if ok2 and cloned2 then
					cloned2.Parent = ViewportFrame
					local cam = ViewportFrame.CurrentCamera
					local pivot = newModel:GetPivot().Position
					local off = newOffset or ElementConfig.ViewportOffset or Vector3.new(0, 2, 5)
					cam.CFrame = CFrame.new(pivot + off, pivot)
				end
			end
		end
	end
	
	if ElementConfig.Buttons and #ElementConfig.Buttons > 0 then
		local ButtonsContainer = New("Frame", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundTransparency = 1,
			AutomaticSize = "Y",
			Parent = Paragraph.UIElements.Container,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 10),
				FillDirection = "Vertical",
			}),
		})

		for _, Button in next, ElementConfig.Buttons do
			local ButtonFrame = CreateButton(
				Button.Title,
				Button.Icon,
				Button.Callback,
				Button.Variant or "White",
				ButtonsContainer,
				nil,
				nil,
				ElementConfig.Window.NewElements and 999 or 10
			)
			ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
		end
	end

	return ParagraphModule.__type, ParagraphModule
end

return Element

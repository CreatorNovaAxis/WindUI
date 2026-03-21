local KeySystem = {}

local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local CreateButton = require("./ui/Button").New
local CreateInput = require("./ui/Input").New

local function closeAndRun(dialog, callback, ...)
	dialog:Close()()
	task.wait(0.4)
	callback(...)
end

function KeySystem.new(Config, Filename, func)
	local KeyDialogInit = require("./window/Dialog").Init(nil, Config.WindUI, Config.WindUI.ScreenGui.KeySystem)
	local KeyDialog = KeyDialogInit.Create(true)

	local HubTitle = Config.Title or "Hub"
	local Services = {}
	local EnteredKey

	local ThumbnailSize = (Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Width) or 200
	local UISize = 430
	if Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Image then
		UISize = 430 + (ThumbnailSize / 2)
	end

	KeyDialog.UIElements.Main.AutomaticSize = "Y"
	KeyDialog.UIElements.Main.Size = UDim2.new(0, UISize, 0, 0)
	
	local IconFrame
	if Config.Icon then
		IconFrame = Creator.Image(Config.Icon, Config.Title .. ":" .. Config.Icon, 0, "Temp", "KeySystem", Config.IconThemed)
		IconFrame.Size = UDim2.new(0, 24, 0, 24)
		IconFrame.LayoutOrder = -1
	end
	
	local Title = New("TextLabel", {
		AutomaticSize = "XY",
		BackgroundTransparency = 1,
		Text = Config.KeySystem.Title or HubTitle,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "Text" },
		TextSize = 20,
	})

	local KeySystemLabel = New("TextLabel", {
		AutomaticSize = "XY",
		BackgroundTransparency = 1,
		Text = "Key System",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		TextTransparency = 0.4,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "Text" },
		TextSize = 16,
	})

	local IconAndTitleContainer = New("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = "XY",
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 14),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
		}),
		IconFrame,
		Title,
	})

	local TitleContainer = New("Frame", {
		AutomaticSize = "Y",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
	}, {
		IconAndTitleContainer,
		KeySystemLabel,
	})
	
	local InputFrame = CreateInput("Enter Key", "solar:key-bold", nil, "Input", function(k)
		EnteredKey = k
	end)
	
	local NoteText
	if Config.KeySystem.Note and Config.KeySystem.Note ~= "" then
		NoteText = New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = "Y",
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			TextXAlignment = "Left",
			Text = Config.KeySystem.Note,
			TextSize = 18,
			TextTransparency = 0.4,
			ThemeTag = { TextColor3 = "Text" },
			BackgroundTransparency = 1,
			RichText = true,
			TextWrapped = true,
		})
	end
	
	local ButtonsContainer = New("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
	}, {
		New("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = "X",
			Size = UDim2.new(0, 0, 1, 0),
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 9),
				FillDirection = "Horizontal",
			}),
		}),
	})
	
	local ThumbnailFrame
	if Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Image then
		local ThumbnailTitle
		if Config.KeySystem.Thumbnail.Title then
			ThumbnailTitle = New("TextLabel", {
				Text = Config.KeySystem.Thumbnail.Title,
				ThemeTag = { TextColor3 = "Text" },
				TextSize = 18,
				FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
				BackgroundTransparency = 1,
				AutomaticSize = "XY",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			})
		end

		ThumbnailFrame = New("ImageLabel", {
			Image = Config.KeySystem.Thumbnail.Image,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, ThumbnailSize, 1, -12),
			Position = UDim2.new(0, 6, 0, 6),
			Parent = KeyDialog.UIElements.Main,
			ScaleType = "Crop",
		}, {
			ThumbnailTitle,
			New("UICorner", { CornerRadius = UDim.new(0, 20) }),
		})
	end
	
	local MainFrame = New("Frame", {
		Size = UDim2.new(1, ThumbnailFrame and -ThumbnailSize or 0, 1, 0),
		Position = UDim2.new(0, ThumbnailFrame and ThumbnailSize or 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = KeyDialog.UIElements.Main,
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 18),
				FillDirection = "Vertical",
			}),
			TitleContainer,
			NoteText,
			InputFrame,
			ButtonsContainer,
			New("UIPadding", {
				PaddingTop    = UDim.new(0, 16),
				PaddingLeft   = UDim.new(0, 16),
				PaddingRight  = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16),
			}),
		}),
	})

	local ExitButton = CreateButton("Exit", "solar:exit-bold", function()
		KeyDialog:Close()()
	end, "Tertiary", ButtonsContainer.Frame)

	if ThumbnailFrame then
		ExitButton.Parent    = ThumbnailFrame
		ExitButton.Size      = UDim2.new(0, 0, 0, 42)
		ExitButton.Position  = UDim2.new(0, 10, 1, -10)
		ExitButton.AnchorPoint = Vector2.new(0, 1)
	end
	
	if Config.KeySystem.URL then
		CreateButton("Get Key", "solar:key-bold", function()
			setclipboard(Config.KeySystem.URL)
			Config.WindUI:Notify({
				Title   = HubTitle,
				Content = "Link copied to clipboard!",
				Image   = "solar:copy-bold",
			})
		end, "Secondary", ButtonsContainer.Frame)
	end
	
	if Config.KeySystem.API then
		local DROPDOWN_WIDTH = 240
		local dropdownOpen   = false

		local ButtonFrame = CreateButton("Get Key", "solar:key-bold", nil, "Secondary", ButtonsContainer.Frame)

		local Divider = Creator.NewRoundFrame(99, "Squircle", {
			Size = UDim2.new(0, 1, 1, 0),
			ThemeTag = { ImageColor3 = "Text" },
			ImageTransparency = 0.9,
		})

		New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = "X",
			Parent = ButtonFrame.Frame,
		}, {
			Divider,
			New("UIPadding", {
				PaddingLeft  = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			}),
		})
		
		local ChevronDown = Creator.Image("solar:square-alt-arrow-down-bold", "solar:square-alt-arrow-down-bold", 0, "Temp", "KeySystem", true)
		ChevronDown.Size = UDim2.new(1, 0, 1, 0)

		New("Frame", {
			Size = UDim2.new(0, 21, 0, 21),
			Parent = ButtonFrame.Frame,
			BackgroundTransparency = 1,
		}, { ChevronDown })

		-- дропдаун
		local DropdownFrame = Creator.NewRoundFrame(15, "Squircle", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = "Y",
			ThemeTag = { ImageColor3 = "Background" },
		}, {
			New("UIPadding", {
				PaddingTop = UDim.new(0, 5), PaddingLeft  = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
			}),
			New("UIListLayout", { FillDirection = "Vertical", Padding = UDim.new(0, 5) }),
		})

		local DropdownContainer = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, DROPDOWN_WIDTH, 0, 0),
			ClipsDescendants = true,
			AnchorPoint = Vector2.new(1, 0),
			Parent = ButtonFrame,
			Position = UDim2.new(1, 0, 1, 15),
		}, { DropdownFrame })

		New("TextLabel", {
			Text = "Select Service",
			BackgroundTransparency = 1,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			ThemeTag = { TextColor3 = "Text" },
			TextTransparency = 0.2,
			TextSize = 16,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = "Y",
			TextWrapped = true,
			TextXAlignment = "Left",
			Parent = DropdownFrame,
		}, {
			New("UIPadding", {
				PaddingTop = UDim.new(0, 10), PaddingLeft  = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
			}),
		})
		
		for _, entry in next, Config.KeySystem.API do
			local serviceDef = Config.WindUI.Services[entry.Type]
			if not serviceDef then continue end

			local args = {}
			for _, argName in next, serviceDef.Args do
				table.insert(args, entry[argName])
			end

			local serviceInstance = serviceDef.New(table.unpack(args))
			serviceInstance.Type = entry.Type
			table.insert(Services, serviceInstance)

			local entryIcon = Creator.Image(
				entry.Icon or serviceDef.Icon or "solar:user-bold",
				entry.Icon or serviceDef.Icon or "solar:user-bold",
				0, "Temp", "KeySystem", true
			)
			entryIcon.Size = UDim2.new(0, 24, 0, 24)

			local APIFrame = Creator.NewRoundFrame(10, "Squircle", {
				Size = UDim2.new(1, 0, 0, 0),
				ThemeTag = { ImageColor3 = "Text" },
				ImageTransparency = 1,
				Parent = DropdownFrame,
				AutomaticSize = "Y",
			}, {
				New("UIListLayout", {
					FillDirection = "Horizontal",
					Padding = UDim.new(0, 10),
					VerticalAlignment = "Center",
				}),
				entryIcon,
				New("UIPadding", {
					PaddingTop = UDim.new(0, 10), PaddingLeft  = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
				}),
				New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -34, 0, 0),
					AutomaticSize = "Y",
				}, {
					New("UIListLayout", {
						FillDirection = "Vertical",
						Padding = UDim.new(0, 5),
					}),
					New("TextLabel", {
						Text = entry.Title or serviceDef.Name,
						BackgroundTransparency = 1,
						FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
						ThemeTag = { TextColor3 = "Text" },
						TextTransparency = 0.05,
						TextSize = 18,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = "Y",
						TextWrapped = true,
						TextXAlignment = "Left",
					}),
					New("TextLabel", {
						Text = entry.Desc or "",
						BackgroundTransparency = 1,
						FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
						ThemeTag = { TextColor3 = "Text" },
						TextTransparency = 0.2,
						TextSize = 16,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = "Y",
						TextWrapped = true,
						Visible = entry.Desc ~= nil,
						TextXAlignment = "Left",
					}),
				}),
			}, true)

			Creator.AddSignal(APIFrame.MouseEnter,      function() Tween(APIFrame, 0.08, { ImageTransparency = 0.95 }):Play() end)
			Creator.AddSignal(APIFrame.InputEnded,      function() Tween(APIFrame, 0.08, { ImageTransparency = 1   }):Play() end)
			Creator.AddSignal(APIFrame.MouseButton1Click, function()
				serviceInstance.Copy()
				Config.WindUI:Notify({
					Title   = HubTitle,
					Content = "Link copied to clipboard!",
					Image   = "solar:copy-bold",
				})
			end)
		end

		Creator.AddSignal(ButtonFrame.MouseButton1Click, function()
			if not dropdownOpen then
				Tween(DropdownContainer, 0.3,  { Size = UDim2.new(0, DROPDOWN_WIDTH, 0, DropdownFrame.AbsoluteSize.Y + 1) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
				Tween(ChevronDown,       0.3,  { Rotation = 180 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			else
				Tween(DropdownContainer, 0.25, { Size = UDim2.new(0, DROPDOWN_WIDTH, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
				Tween(ChevronDown,       0.25, { Rotation = 0   }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			end
			dropdownOpen = not dropdownOpen
		end)
	end

	local function handleSuccess(key)
		if Config.KeySystem.SaveKey then
			local saveFolder = Config.Folder or "Temp"
			writefile(saveFolder .. "/" .. Filename .. ".key", tostring(key))
		end
		closeAndRun(KeyDialog, func, true)
	end

	local function notifyError(message)
		Config.WindUI:Notify({
			Title   = HubTitle,
			Content = message,
			Image   = "solar:danger-triangle-bold",
		})
	end

	local SubmitButton = CreateButton("Submit", "solar:square-alt-arrow-right-bold", function()
		local key = tostring(EnteredKey or "")

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.KeyValidator(key) then
				handleSuccess(key)
			else
				notifyError("Invalid key!")
			end

		elseif Config.KeySystem.API then
			local isValid, errMsg = false, "Verification failed"
			for _, service in next, Services do
				local ok, res = service.Verify(key)
				if ok then
					isValid = true
					break
				end
				errMsg = tostring(res)
			end

			if isValid then
				handleSuccess(key)
			else
				notifyError("Error: " .. errMsg)
			end

		else
			local isValid = type(Config.KeySystem.Key) == "table"
				and table.find(Config.KeySystem.Key, key) ~= nil
				or Config.KeySystem.Key == key

			if isValid then
				handleSuccess(key)
			else
				notifyError("Invalid key!")
			end
		end
	end, "Primary", ButtonsContainer)

	SubmitButton.AnchorPoint = Vector2.new(1, 0.5)
	SubmitButton.Position    = UDim2.new(1, 0, 0.5, 0)

	KeyDialog:Open()
end

return KeySystem

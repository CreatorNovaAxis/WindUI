local Section = {}


local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local TabModule = require("./Tab")

function Section.New(SectionConfig, Parent, Folder, UIScale, Window)
    local SectionModule = {
        Title = SectionConfig.Title or "Section",
        Icon = SectionConfig.Icon,
        IconColor = SectionConfig.IconColor,
        IconShape = SectionConfig.IconShape,
        IconThemed = SectionConfig.IconThemed,
        Opened = SectionConfig.Opened or false,
        
        HeaderSize = 42,
        IconSize = 18,
        
        Expandable = false,
    }
    
    local IconFrame
    local IconContainer
    local HasIconShape = SectionModule.IconShape and SectionModule.IconColor
    
    if SectionModule.Icon then
        IconFrame = Creator.Image(
            SectionModule.Icon,
            SectionModule.Icon,
            0,
            Folder,
            "Section",
            SectionModule.IconColor and false or true,
            SectionModule.IconThemed,
            "TabSectionIcon"
        )
        
        if SectionModule.IconColor then
            IconFrame.ImageLabel.ImageColor3 = SectionModule.IconColor
        end
        
        if HasIconShape then
            local cornerRadius = SectionModule.IconShape ~= "Circle" and (Window.ElementConfig.UICorner - 6) or 9999
            
            IconContainer = Creator.NewRoundFrame(
                cornerRadius,
                "Squircle",
                {
                    Size = UDim2.new(0, SectionModule.IconSize + 8, 0, SectionModule.IconSize + 8),
                    ImageColor3 = SectionModule.IconColor,
                    BackgroundTransparency = 1,
                },
                {
                    IconFrame,
                    Creator.NewRoundFrame(
                        cornerRadius,
                        "Glass-1.4",
                        {
                            Size = UDim2.new(1, 0, 1, 0),
                            ThemeTag = {
                                ImageColor3 = "White",
                            },
                            ImageTransparency = 0,
                            Name = "Outline",
                        }
                    ),
                }
            )
            IconFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            IconFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            IconFrame.Size = UDim2.new(0, SectionModule.IconSize, 0, SectionModule.IconSize)
            IconFrame.ImageLabel.ImageTransparency = 0
            IconFrame.ImageLabel.ImageColor3 = Creator.GetTextColorForHSB(SectionModule.IconColor, 0.68)
        else
            IconContainer = IconFrame
            IconContainer.Size = UDim2.new(0, SectionModule.IconSize, 0, SectionModule.IconSize)
            IconContainer.ImageLabel.ImageTransparency = .25
        end
    end
    
    local ChevronIconFrame = New("Frame", {
        Size = UDim2.new(0,SectionModule.IconSize,0,SectionModule.IconSize),
        BackgroundTransparency = 1,
        Visible = false
    }, {
        New("ImageLabel", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Image = Creator.Icon("chevron-down")[1],
            ImageRectSize = Creator.Icon("chevron-down")[2].ImageRectSize,
            ImageRectOffset = Creator.Icon("chevron-down")[2].ImageRectPosition,
            ThemeTag = {
                ImageColor3 = "Icon",
            },
            ImageTransparency = .7,
        })
    })
    
    local SectionFrame = New("Frame", {
        Size = UDim2.new(1,0,0,SectionModule.HeaderSize),
        BackgroundTransparency = 1,
        Parent = Parent,
        ClipsDescendants = true,
    }, {
        New("TextButton", {
            Size = UDim2.new(1,0,0,SectionModule.HeaderSize),
            BackgroundTransparency = 1,
            Text = "",
        }, {
            IconContainer,
            New("TextLabel", {
                Text = SectionModule.Title,
                TextXAlignment = "Left",
                Size = UDim2.new(
                    1, 
                    IconContainer and (-(HasIconShape and SectionModule.IconSize + 8 or SectionModule.IconSize)-10)*2
                        or (-SectionModule.IconSize-10),
                        
                    1,
                    0
                ),
                ThemeTag = {
                    TextColor3 = "Text",
                },
                FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
                TextSize = 14,
                BackgroundTransparency = 1,
                TextTransparency = .7,
                --TextTruncate = "AtEnd",
                TextWrapped = true
            }),
            New("UIListLayout", {
                FillDirection = "Horizontal",
                VerticalAlignment = "Center",
                Padding = UDim.new(0,10)
            }),
            ChevronIconFrame,
            New("UIPadding", {
                PaddingLeft = UDim.new(0,11),
                PaddingRight = UDim.new(0,11),
            })
        }),
        New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            Name = "Content",
            Visible = true,
            Position = UDim2.new(0,0,0,SectionModule.HeaderSize)
        }, {
            New("UIListLayout", {
                FillDirection = "Vertical",
                Padding = UDim.new(0,Window.Gap),
                VerticalAlignment = "Bottom",
            }),
        })
    })
    
    
    function SectionModule:Tab(TabConfig)
        if not SectionModule.Expandable then
            SectionModule.Expandable = true
            ChevronIconFrame.Visible = true
        end
        TabConfig.Parent = SectionFrame.Content
        return TabModule.New(TabConfig, UIScale)
    end
    
    function SectionModule:Open()
        if SectionModule.Expandable then
            SectionModule.Opened = true
            Tween(SectionFrame, 0.33, {
                Size = UDim2.new(1,0,0, SectionModule.HeaderSize + (SectionFrame.Content.AbsoluteSize.Y/UIScale))
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            Tween(ChevronIconFrame.ImageLabel, 0.1, {Rotation = 180}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end
    end
    function SectionModule:Close()
        if SectionModule.Expandable then
            SectionModule.Opened = false
            Tween(SectionFrame, 0.26, {
                Size = UDim2.new(1,0,0, SectionModule.HeaderSize)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            Tween(ChevronIconFrame.ImageLabel, 0.1, {Rotation = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end
    end
    
    Creator.AddSignal(SectionFrame.TextButton.MouseButton1Click, function()
        if SectionModule.Expandable then
            if SectionModule.Opened then
                SectionModule:Close()
            else
                SectionModule:Open()
            end
        end
    end)
    
    Creator.AddSignal(SectionFrame.Content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if SectionModule.Opened then
            SectionModule:Open()
        end
    end)
    
    if SectionModule.Opened then
        task.spawn(function()
            task.wait()
            SectionModule:Open()
        end)
    end

    
    
    return SectionModule
end


return Section

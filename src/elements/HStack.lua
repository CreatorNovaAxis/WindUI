local Creator = require("../modules/Creator")
local New = Creator.New

local Element = {}

function Element:New(Config)

    local HStackModule = {
        __type = "HStack",

        AutoSpace = Config.AutoSpace or false,

        Elements = {},

        ElementFrame = nil,
        Layout = nil,
    }

    local HStackFrame = New("Frame", {
        Name = "HStack",

        Size = UDim2.new(1, 0, 0, 0),

        BackgroundTransparency = 1,

        AutomaticSize = "Y",

        Parent = Config.Parent,
    })

    local Gap =
        Config.Tab
        and Config.Tab.Gap
        or (Config.Window.NewElements and 1 or 6)

    local Layout = New("UIListLayout", {
        FillDirection = "Horizontal",

        HorizontalAlignment = "Center",

        SortOrder = Enum.SortOrder.LayoutOrder,

        Padding = UDim.new(0, Gap),

        Parent = HStackFrame,
    })

    HStackModule.ElementFrame = HStackFrame
    HStackModule.Layout = Layout

    local ElementsModule = Config.ElementsModule

    ElementsModule.Load(
        HStackModule,
        HStackFrame,
        ElementsModule.Elements,

        Config.Window,
        Config.WindUI,

        function(CurrentElement, AllElements)

            local StretchableElements = {}
            local TotalFixedWidth = 0

            for _, ElementObject in next, AllElements do

                if ElementObject.__type == "Space" then

                    TotalFixedWidth +=
                        (ElementObject.ElementFrame
                        and ElementObject.ElementFrame.Size.X.Offset)
                        or 6

                elseif ElementObject.__type == "Divider" then

                    TotalFixedWidth +=
                        (ElementObject.ElementFrame
                        and ElementObject.ElementFrame.Size.X.Offset)
                        or 1

                else
                    table.insert(StretchableElements, ElementObject)
                end
            end

            local StretchCount = #StretchableElements

            if StretchCount <= 0 then
                return
            end

            local ElementWidthScale = 1 / StretchCount

            local TotalGapWidth = Gap * math.max(0, StretchCount - 1)

            local TotalOffset =
                -(TotalGapWidth + TotalFixedWidth)

            local BaseOffset =
                math.floor(TotalOffset / StretchCount)

            local Remainder =
                TotalOffset - (BaseOffset * StretchCount)

            for i, ElementObject in next, StretchableElements do

                local Offset = BaseOffset

                if i <= math.abs(Remainder) then
                    Offset -= 1
                end

                pcall(function()

                    if ElementObject.ElementFrame then
                        ElementObject.ElementFrame.Size = UDim2.new(
                            ElementWidthScale,
                            Offset,
                            1,
                            0
                        )
                    end
                end)
            end
        end,

        ElementsModule,
        Config.UIScale,
        Config.Tab
    )

    if HStackModule.AutoSpace then

        for name in next, ElementsModule.Elements do

            if name ~= "Space"
                and name ~= "Divider" then

                local original = HStackModule[name]

                HStackModule[name] = function(self, config)

                    if #HStackModule.Elements > 0 then
                        HStackModule:Space()
                    end

                    return original(self, config)
                end
            end
        end
    end

    function HStackModule:AddElement(element)
        table.insert(self.Elements, element)
    end
    
    function HStackModule:RemoveElement(element)

        local index = table.find(self.Elements, element)

        if index then

            table.remove(self.Elements, index)

            pcall(function()

                if element.Destroy then
                    element:Destroy()

                elseif element.ElementFrame then
                    element.ElementFrame:Destroy()
                end
            end)
        end
    end

    function HStackModule:Clear()

        for _, element in ipairs(self.Elements) do

            pcall(function()

                if typeof(element) == "Instance" then
                    element:Destroy()

                elseif type(element) == "table" then

                    if element.Destroy then
                        element:Destroy()

                    elseif element.ElementFrame then
                        element.ElementFrame:Destroy()

                    elseif element.UIElements
                        and element.UIElements.Main then

                        element.UIElements.Main:Destroy()
                    end
                end
            end)
        end

        table.clear(self.Elements)
    end
    
    function HStackModule:Destroy()

        self:Clear()

        pcall(function()
            if self.Layout then
                self.Layout:Destroy()
            end
        end)

        pcall(function()
            if self.ElementFrame then
                self.ElementFrame:Destroy()
            end
        end)

        self.Layout = nil
        self.ElementFrame = nil

        table.clear(self.Elements)
    end
    
    function HStackModule:GetHeight()

        if not self.ElementFrame then
            return 0
        end

        return self.ElementFrame.AbsoluteSize.Y
    end

    function HStackModule:SetGap(value)

        if self.Layout then
            self.Layout.Padding = UDim.new(0, value)
        end
    end

    function HStackModule:FindElementByType(typeName)

        for _, element in ipairs(self.Elements) do

            if element.__type == typeName then
                return element
            end
        end
    end

    function HStackModule:GetElements()
        return self.Elements
    end

    return HStackModule.__type, HStackModule
end

return Element

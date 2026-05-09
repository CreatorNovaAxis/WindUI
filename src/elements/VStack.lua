local Creator = require("../modules/Creator")
local New = Creator.New

local Element = {}

function Element:New(Config)

    local VStackModule = {
        __type = "VStack",

        Elements = {},

        ElementFrame = nil,
        Layout = nil,
    }

    local VStackFrame = New("Frame", {
        Name = "VStack",

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
        FillDirection = "Vertical",

        HorizontalAlignment = "Center",

        SortOrder = Enum.SortOrder.LayoutOrder,

        Padding = UDim.new(0, Gap),

        Parent = VStackFrame,
    })

    VStackModule.ElementFrame = VStackFrame
    VStackModule.Layout = Layout

    local ElementsModule = Config.ElementsModule

    ElementsModule.Load(
        VStackModule,
        VStackFrame,
        ElementsModule.Elements,

        Config.Window,
        Config.WindUI,

        nil,

        ElementsModule,
        Config.UIScale,
        Config.Tab
    )

    function VStackModule:AddElement(element)
        table.insert(self.Elements, element)
    end

    function VStackModule:RemoveElement(element)
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

    function VStackModule:Clear()

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

    function VStackModule:Destroy()

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

    function VStackModule:GetHeight()

        if not self.ElementFrame then
            return 0
        end

        return self.ElementFrame.AbsoluteSize.Y
    end
    
    function VStackModule:SetGap(value)

        if self.Layout then
            self.Layout.Padding = UDim.new(0, value)
        end
    end

    function VStackModule:FindElementByType(typeName)

        for _, element in ipairs(self.Elements) do
            if element.__type == typeName then
                return element
            end
        end
    end
    
    function VStackModule:GetElements()
        return self.Elements
    end

    return VStackModule.__type, VStackModule
end

return Element

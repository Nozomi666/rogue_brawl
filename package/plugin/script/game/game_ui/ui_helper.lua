local mt = {}
uiHelper = mt

mt.anchorPos = {
    TOP_LEFT = {0, 0},
    TOP_CENTER = {0.5, 0},
    TOP_RIGHT = {1, 0},
    LEFT = {0, 0.5},
    CENTER = {0.5, 0.5},
    RIGHT = {1, 0.5},
    BOT_LEFT = {0, 1},
    BOT_CENTER = {0.5, 1},
    BOT_RIGHT = {1, 1},
}

mt.SCREEN_WIDTH = 1920
mt.SCREEN_HEIGHT = 1080
mt.GAME_UI = class.panel.create(nil, 0, 0, mt.SCREEN_WIDTH, mt.SCREEN_HEIGHT)

mt.textureAnimList = {}
mt.textureAnimListFast = {}

MAIN_UI = mt.GAME_UI
-- MAIN_UI.layer = {}
-- for i = 1, 5 do
--     local frame = class.panel.new(MAIN_UI, [[]], 0, 0, mt.SCREEN_WIDTH, mt.SCREEN_HEIGHT)
--     -- frame:set_level(i)
--     MAIN_UI.layer[i] = frame
-- end
ANCHOR = mt.anchorPos

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
function mt:setFrameAnchor(frameMain, anchorMain, frameSupport, anchorSupport, shiftX, shiftY)
    local fSupportX, fSupportY = frameSupport:get_real_position()

    local fMainW = frameMain:get_width()
    local fMainH = frameMain:get_height()
    local fSupportW = frameSupport:get_width()
    local fSupportH = frameSupport:get_height()

    local deltaX, deltaY = 0, 0

    deltaX = deltaX + fSupportW * anchorSupport[1] - fMainW * anchorMain[1]
    deltaY = deltaY + fSupportH * anchorSupport[2] - fMainH * anchorMain[2]

    local afterX = fSupportX + deltaX + shiftX
    local afterY = fSupportY + deltaY + shiftY

    frameMain:set_real_position(afterX, afterY)
end
--------------------------------------------------------------------------------------
mt.screenWidthPercent = function(percent)
    return percent * mt.SCREEN_WIDTH
end
--------------------------------------------------------------------------------------
mt.screenHeightPercent = function(percent)
    return percent * mt.SCREEN_HEIGHT
end
--------------------------------------------------------------------------------------
fc.setFramePos = function(frameMain, anchorMain, frameSupport, anchorSupport, shiftX, shiftY)
    mt:setFrameAnchor(frameMain, anchorMain, frameSupport, anchorSupport, shiftX, shiftY)
end
--------------------------------------------------------------------------------------
fc.setFrameGridPos = function(frameMain, anchorMain, frameSupport, anchorSupport, startX, startY, rollSpace, columSpace,
    rollNum, columNum)
    local shiftX = startX + columSpace * (columNum - 1)
    local shiftY = startY + rollSpace * (rollNum - 1)
    fc.setFramePos(frameMain, anchorMain, frameSupport, anchorSupport, shiftX, shiftY)
end
--------------------------------------------------------------------------------------
fc.setFramePosPct = function(frameMain, anchorMain, frameSupport, anchorSupport, shiftXPct, shiftYPct)
    local shiftX = mt.screenWidthPercent(shiftXPct)
    local shiftY = mt.screenHeightPercent(shiftYPct)
    mt:setFrameAnchor(frameMain, anchorMain, frameSupport, anchorSupport, shiftX, shiftY)
end
--------------------------------------------------------------------------------------
fc.setBtnImgActive = function(btn, tag, normalPath, activePath)
    local p = as.player:getLocalPlayer()
    local attrTag = 'btnImgActive' .. tag
    local prevBtn = p:getAttr(attrTag)
    local prevPath = p:getAttr(attrTag .. 'normalPath')
    if prevBtn then
        prevBtn:set_normal_image(prevPath)
    end

    btn:set_normal_image(activePath)
    p:setAttr(attrTag, btn)
    p:setAttr(attrTag .. 'normalPath', normalPath)

end
--------------------------------------------------------------------------------------
mt.flexWindows = {}
--------------------------------------------------------------------------------------
function mt.regFlexWindow(component)
    table.insert(mt.flexWindows, component)

end
--------------------------------------------------------------------------------------
function mt.changeWindowSize(p)

    gdebug('change window size')
    if not p:isLocal() then
        return
    end

    if code.checkIsReply() ~= 1 then
        return
    end

    screenRatio = 1
    if dz.DzGetWindowHeight() / dz.DzGetWindowWidth() > 0.74 and dz.DzGetWindowHeight() / dz.DzGetWindowWidth() < 0.76 then
        screenRatio = 1.3333
        classicUI = true
    else
        screenRatio = 1
        classicUI = false
    end

    local renderList = reg:getPool('ui_render_list')
    for _, component in ipairs(renderList) do
        if component:get_is_show() then
            component:measure()
            component:draw()
        end

    end
end
--------------------------------------------------------------------------------------
function mt.autoAdjustWindowSize()
    local GetWindowWidth = japi.GetWindowWidth
    local GetWindowHeight = japi.GetWindowHeight
    local IsWindowMode = japi.IsWindowMode
    local SetWindowSize = japi.SetWindowSize

    if localEnv then
        return
    end

    local ffi = require 'ffi'

    ffi.cdef [[
    int system(const char *command);
    int GetFocus();
    bool IsZoomed(int hwnd);
    int GetSystemMetrics(int index);
    int SetWindowPos(int hwnd,int hWndInsertAfter,int x,int y,int cx,int cy,int wFlags);
    int FindWindowA(const char * lpClassName,const char * lpWindowName);
    int FindWindowExA(int hwnd, int childAfter, const char * className, const char * windowTitle);
    int GetConsoleWindow();
    int rand();
    void srand(int seed);
    const char * GetCommandLineA();
    int GetModuleHandleA(const char* lpModuleName);
]]

    local getSystemMetrics = ffi['C']['GetSystemMetrics']
    local getCommandLineA = ffi['C']['GetCommandLineA']
    local getModuleHandleA = ffi['C']['GetModuleHandleA']
    local setWindowPos = ffi['C']['SetWindowPos']
    local findWindowExA = ffi['C']['FindWindowExA']

    local cast = ffi['cast']
    local toStr = ffi['string']

    local game = getModuleHandleA("Game.dll")
    local hwnd = cast("int *", game + 0xBDA9CC)[0]
    local window_flag = not not toStr(getCommandLineA()):lower():find("-window")

    local function system_window_width()
        return getSystemMetrics(0)
    end

    local function system_window_height()
        return getSystemMetrics(1)
    end

    local function set_window_size(width, height, is_center)
        width = math.floor(width)
        height = math.floor(height)
        -- gdebug('set_window_size 1111')
        if window_flag and not ffi['C']['IsZoomed'](hwnd) then
            if is_center then
                -- gdebug('set_window_size 2222')
                local x = (system_window_width() - width) / 2
                local y = (system_window_height() - height) / 2
                setWindowPos(hwnd, 0, x, y, width, height, 0x0004)
            else
                -- gdebug('set_window_size 3333')
                setWindowPos(hwnd, 0, 0, 0, width, height, 0x0002 | 0x0004)
            end
        end
    end

    if code.checkIsReply() == 1 then
        if dz.DzGetWindowHeight() / dz.DzGetWindowWidth() > 0.74 and dz.DzGetWindowHeight() / dz.DzGetWindowWidth() <
            0.76 then
            -- screenRatio = 1.3333
            -- classicUI = true
            local w, h = GetWindowWidth(), GetWindowHeight()
            if (IsWindowMode()) then
                w = h / 9 * 16
                dz.DzEnableWideScreen(true)
                SetWindowSize(w, w * 9 / 16)
            end

            screenRatio = 1
            classicUI = false

        else
            screenRatio = 1
            classicUI = false
        end

        local retio = 1080 / 1920
        if IsWindowMode() then
            gdebug('is window mode')
            local width = system_window_width() * 0.8
            local height = width * retio
            if height >= system_window_height() * 0.9 then
                height = system_window_height() * 0.8
                width = height / retio
            end
            gdebug('is window width: ' .. width)
            gdebug('is window height: ' .. height)
            set_window_size(width, height, true)
        end

    end
end
--------------------------------------------------------------------------------------
function fc.setFrameDragable(uiFrame, backBtn)

    backBtn.is_drag = true

    function backBtn:on_button_begin_drag()
        backBtn.mouseOffX = nil
        backBtn.mouseOffY = nil
        -- gdebug('begin drag 1111111')
    end

    function backBtn:on_button_update_drag(icon, x, y)
        -- gdebug('begin drag 2222222')
        icon:hide()
        local xMouse, yMouse = game.get_mouse_pos()
        if not backBtn.mouseOffX then
            local xPanel, yPanel = backBtn:get_real_position()
            backBtn.mouseOffX = xMouse - xPanel
            backBtn.mouseOffY = yMouse - yPanel
        end

        local posX = xMouse - backBtn.mouseOffX
        local posY = yMouse - backBtn.mouseOffY

        uiFrame:set_real_position(posX, posY)

    end
end
--------------------------------------------------------------------------------------
function mt.update()
    for i, texture in ipairs(mt.textureAnimList) do
        if texture.isPlaying then
            local frameNum = #texture.animTexturePathList
            texture.currentFrameId = texture.currentFrameId + 1
            if texture.currentFrameId > frameNum then
                if texture.isLoop then
                    texture.currentFrameId = 0
                else
                    texture.isPlaying = false
                    texture:hide()
                end
            else
                texture:set_normal_image(texture.animTexturePathList[texture.currentFrameId])
            end

        end
    end
end
--------------------------------------------------------------------------------------
function mt.updateFast()
    for i, texture in ipairs(mt.textureAnimListFast) do
        if texture.isPlaying then
            local frameNum = #texture.animTexturePathList
            texture.currentFrameId = texture.currentFrameId + 1
            if texture.currentFrameId > frameNum then
                if texture.isLoop then
                    texture.currentFrameId = 0
                else
                    texture.isPlaying = false
                    texture:hide()
                end
            else
                texture:set_normal_image(texture.animTexturePathList[texture.currentFrameId])
            end

        end
    end
end
--------------------------------------------------------------------------------------
ac.loop(ms(0.03), function()

end)
--------------------------------------------------------------------------------------
function fc.setTextureBeAnim(texture, isLoop)
    texture.isAnimTexture = true
    texture.currentFrameId = 0
    texture.isLoop = isLoop
    texture.isPlaying = false
    texture:hide()
    table.insert(mt.textureAnimList, texture)
end
--------------------------------------------------------------------------------------
function fc.setTextureBeAnimFast(texture, isLoop)
    texture.isAnimTexture = true
    texture.currentFrameId = 0
    texture.isLoop = isLoop
    texture.isPlaying = false
    texture:hide()
    table.insert(mt.textureAnimListFast, texture)
end
--------------------------------------------------------------------------------------
function fc.playTextureAnim(texture)
    texture.isPlaying = true
    texture.currentFrameId = 0
    texture:show()
end
--------------------------------------------------------------------------------------
function fc.stopTextureAnim(texture)
    texture.isPlaying = false
    texture:hide()

end
--------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------
-- function mt.checkUpdateWindow(component)
--     if component.needUpdateWindow then
--         component:measure()
--         component:draw()
--     end
-- end
--------------------------------------------------------------------------------------
-- function fc.remeasureSize(component)
--     local oldW = component:get_width()
--     local oldH = component:get_height()

-- end

--------------------------------------------------------------------------------------

return mt

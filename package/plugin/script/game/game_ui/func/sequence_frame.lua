local mt = {}

--------------------------------------------------------------------------------------
function mt:update()

    --------------------------------------------------------------------------------------



    --------------------------------------------------------------------------------------
    -- Q群流光
    -- if GUI.AddQQBtn.bUpdateFrame then
    --     GUI.AddQQBtn:onUpdateFrame()
    -- end

end
--------------------------------------------------------------------------------------
function mt:updateFast()

    GUI.GameMessage.update()
    --------------------------------------------------------------------------------------
    GUI.UnitInfo:updateBoardFast()


    --------------------------------------------------------------------------------------
    -- 资源不足提示
    if GUI.NotEnoughResource.phaseFading then
        local self = GUI.NotEnoughResource
        if self.fadeAlpha > 0 then
            self.fadeAlpha = self.fadeAlpha - 0.05
            self:set_alpha(self.fadeAlpha)
            self.offSetVal = self.offSetVal + self.offSetDelta
            fc.setFramePos(self, ANCHOR.BOT_CENTER, self.btnFrame, ANCHOR.TOP_CENTER, self.offSetX, self.offSetVal)
            if self.fadeAlpha <= 0 then
                self:hide()
                self.phaseFading = false
            end
        end
    end

    --------------------------------------------------------------------------------------
    -- 移动选赐福的图标
    class.pick_bless_moving_btn.updateAllBoard()

    --------------------------------------------------------------------------------------


end
--------------------------------------------------------------------------------------
GUI.SequenceFrame = mt

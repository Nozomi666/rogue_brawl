local mt = {}
AudioManager = mt
--------------------------------------------------------------------------------------
mt.normalBgmList = nil
mt.bossBgm = nil
mt.finalBossBgm = nil
mt.currentMusic = nil
mt.normalBgmIndexCounter = 0
--------------------------------------------------------------------------------------
function mt:start()
    self.normalBgmList = gm.mapArea.normalBgmList
    self.bossBgm = gm.mapArea.bossBgm
    self.finalBossBgm = gm.mapArea.finalBossBgm

    fc.shuffleTable(self.normalBgmList)

    self:playRandomNormalBgm()

end
--------------------------------------------------------------------------------------
function mt:onEverySec()

end
--------------------------------------------------------------------------------------
function mt:playRandomNormalBgm()
    local bgmListLength = #self.normalBgmList
    local playId = (self.normalBgmIndexCounter % bgmListLength) + 1
    self.normalBgmIndexCounter = self.normalBgmIndexCounter + 1

    if playId == bgmListLength then
        fc.shuffleTable(self.normalBgmList)
    end

    local music = glo[self.normalBgmList[playId].name]
    local musicLength = self.normalBgmList[playId].length

    gdebug('play music: %s, length: %.0f', self.normalBgmList[playId], musicLength)

    self:playMusic(music, function(self)
        self:playRandomNormalBgm()
    end, musicLength)

end
--------------------------------------------------------------------------------------
function mt:play61Bgm(pack, player)
    local music = glo[pack.bgmName]
    local musicLength = pack.bgmLength

    if player:isLocal() then
        StopMusic(true)
    end

    ac.wait(ms(2.5), function()
        local p = as.player:getLocalPlayer()
        if player:isLocal() and not p.closeMusic then
            PlayMusicBJ(music)
        end
        ac.wait(ms(musicLength),function ()
            if player:isLocal() then
                StopMusic(true)
            end
            ac.wait(ms(2.5), function()
                if player:isLocal() then
                    PlayMusicBJ(self.readyPlayMusic)
                end
            end)
            
        end)
    end)

end
--------------------------------------------------------------------------------------
function mt:playBossBgm()
    local music = glo[self.bossBgm.name]
    local musicLength = self.bossBgm.length

    self:playMusic(music, function(self)
        self:playBossBgm()
    end, musicLength)
end
--------------------------------------------------------------------------------------
function mt:playCloseToEndBgm()
    local music = glo.gg_snd_bgm_close_to_end
    local musicLength = 101

    self:playMusic(music, function(self)
        self:playCloseToEndBgm()
    end, musicLength)
end
--------------------------------------------------------------------------------------
function mt:playFinalBossBgm()
    local music = glo[self.finalBossBgm.name]
    local musicLength = self.finalBossBgm.length

    self:playMusic(music, function(self)
        self:playFinalBossBgm()
    end, musicLength)
end
--------------------------------------------------------------------------------------
function mt:playMusic(music, onMusicPlayComplete, musicLength, player)

    if not self.playMusicComplete then
        if self.musicCountdownTimer then
            self.musicCountdownTimer:remove()
        end
    end

    self.playMusicComplete = false
    self.readyPlayMusic = music

    self.musicCountdownTimer = ac.wait(ms(musicLength + 2.5), function()
        self.playMusicComplete = true
        onMusicPlayComplete(self)
    end)

    if not self.playMusicBufferTimer then
        StopMusic(true)
        self.playMusicBufferTimer = ac.wait(ms(2.5), function()
            local p = as.player:getLocalPlayer()
            if not p.closeMusic then
                PlayMusicBJ(self.readyPlayMusic)
            end
            self.playMusicBufferTimer = nil
        end)
    end

end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
return mt

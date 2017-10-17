local endsWith = function (str, value)
  return string.sub(str, -string.len(value)) == value
end

local frame = CreateFrame('Frame')

local text = frame:CreateFontString(nil, 'OVERLAY')
text:SetPoint('CENTER', UIParent, 'CENTER', 0, -200)
text:SetShadowOffset(1, -1.25)
text:SetShadowColor(0, 0, 0, 1)
text:SetTextColor(1, 1, 1)
text:SetFont('Fonts\\FRIZQT__.TTF', 14)

frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

local animationGroup = frame:CreateAnimationGroup()
local animation = animationGroup:CreateAnimation('Alpha')
animation:SetStartDelay(2)
animation:SetDuration(0.5)
animation:SetSmoothing('IN')
animation:SetFromAlpha(1)
animation:SetToAlpha(0)

animationGroup:SetScript('OnFinished', function()
  frame:SetAlpha(0)
end)

frame:SetScript('OnEvent', function (_, _, ...)
  local subEvent = select(2, ...)
  local destGuid = select(8, ...)

  -- we only care about damage events that happened to the player
  if not endsWith(subEvent, '_DAMAGE') or destGuid ~= UnitGUID('player') then
    return
  end

  -- this changes based on the sub event because of course it does
  local damageIndex = 15

  if subEvent == 'SWING_DAMAGE' then
    damageIndex = 12
  elseif subEvent == 'ENVIRONMENTAL_DAMAGE' then
    damageIndex = 13
  end

  local damage = select(damageIndex, ...)

  text:SetText(damage)

  if animationGroup:IsPlaying() then animationGroup:Stop() end

  frame:SetAlpha(1)
  animationGroup:Play()
end)

local endsWith = function (str, value)
  return string.sub(str, -string.len(value)) == value
end

local displayDamage = function (damage)
  local frame = CreateFrame('Frame')
  local text = frame:CreateFontString(nil, 'OVERLAY')
  text:SetPoint('CENTER', UIParent, 'CENTER', 0, -100)
  text:SetShadowOffset(1, -1.25)
  text:SetShadowColor(0, 0, 0, 1)
  text:SetTextColor(1, 1, 1)
  text:SetFont('Fonts\\FRIZQT__.TTF', 14)

  text:SetText('-' .. damage)

  local animationGroup = frame:CreateAnimationGroup()
  local fade = animationGroup:CreateAnimation('Alpha')
  fade:SetStartDelay(1)
  fade:SetDuration(0.2)
  fade:SetOrder(1)
  fade:SetSmoothing('IN')
  fade:SetFromAlpha(1)
  fade:SetToAlpha(0)

  local translation = animationGroup:CreateAnimation('Translation')
  translation:SetDuration(1.2)
  translation:SetOrder(1)
  translation:SetOffset(0, -100)

  animationGroup:SetScript('OnFinished', function ()
    frame:SetAlpha(0)
  end)

  animationGroup:Play()
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

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

  displayDamage(damage)
end)

local endsWith = function (str, value)
  return string.sub(str, -string.len(value)) == value
end

local function prettifyNumber(n)
  n = math.floor(n + 0.5) -- round to nearest whole number

  -- credit to Richard Warburton (http://richard.warburton.it)
  -- via http://lua-users.org/wiki/FormattingNumbers
  local left, num, right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')

  return left .. num:reverse():gsub('(%d%d%d)', '%1,'):reverse() .. right
end

local framePool = {}

local createScrollingText = function (frame)
  frame.text = frame:CreateFontString(nil, 'OVERLAY')
  frame.text:SetShadowOffset(1, -1.25)
  frame.text:SetShadowColor(0, 0, 0, 1)
  frame.text:SetTextColor(1, 1, 1)
  frame.text:SetFont('Fonts\\FRIZQT__.TTF', 14)

  frame.animationGroup = frame:CreateAnimationGroup()
  frame.fade = frame.animationGroup:CreateAnimation('Alpha')
  frame.fade:SetStartDelay(1)
  frame.fade:SetDuration(0.2)
  frame.fade:SetOrder(1)
  frame.fade:SetSmoothing('IN')
  frame.fade:SetFromAlpha(1)
  frame.fade:SetToAlpha(0)

  frame.translation = frame.animationGroup:CreateAnimation('Translation')
  frame.translation:SetDuration(1.2)
  frame.translation:SetOrder(1)
  frame.translation:SetOffset(0, -100)

  frame.animationGroup:SetScript('OnFinished', function ()
    frame:SetAlpha(0)
    table.insert(framePool, frame)
  end)
end

local displayDamage = function (damage)
  local frame = table.remove(framePool) or CreateFrame('Frame')
  frame:SetAlpha(1)

  if not frame.text then
    createScrollingText(frame)
  end

  frame.text:SetPoint('CENTER', UIParent, 'CENTER', -100, -100)

  frame.animationGroup:Play()
  frame.text:SetText('|cffe85d75-' .. prettifyNumber(damage) .. '|r')
end

local displayHealing = function (healing)
  local frame = table.remove(framePool) or CreateFrame('Frame')
  frame:SetAlpha(1)

  if not frame.text then
    createScrollingText(frame)
  end

  frame.text:SetPoint('CENTER', UIParent, 'CENTER', 100, -100)

  frame.text:SetText('|cffadc7a6+' .. prettifyNumber(healing) .. '|r')
  frame.animationGroup:Play()
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

local totalDamage = 0
local totalHealing = 0

frame:SetScript('OnEvent', function (_, _, ...)
  local subEvent = select(2, ...)
  local destGuid = select(8, ...)

  -- we only care about events that happened to the player
  if destGuid ~= UnitGUID('player') then return end

  if endsWith(subEvent, '_DAMAGE') then
    -- this changes based on the sub event because of course it does
    local damageIndex = 15

    if subEvent == 'SWING_DAMAGE' then
      damageIndex = 12
    elseif subEvent == 'ENVIRONMENTAL_DAMAGE' then
      damageIndex = 13
    end

    totalDamage = totalDamage + select(damageIndex, ...)

    return
  end

  if endsWith(subEvent, '_HEAL') then
    local healing, overhealing = select(15, ...)

    totalHealing = totalHealing + healing - overhealing
  end
end)

local damageTimer = 0
local healingTimer = 0

frame:SetScript('OnUpdate', function (_, elapsed)
  damageTimer = damageTimer + elapsed
  healingTimer = healingTimer + elapsed

  if damageTimer >= 1 and totalDamage > 0 then
    displayDamage(totalDamage)
    totalDamage = 0
    damageTimer = 0
  end

  if healingTimer >= 1 and totalHealing > 0 then
    displayHealing(totalHealing)
    totalHealing = 0
    healingTimer = 0
  end
end)

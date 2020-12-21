SLASH_PLUSLISTVERBOSE1 = '/pluslist'
SLASH_PLUSLISTBRIEF1 = '/pl'

if not WeeklyRewardsFrame then
  WeeklyRewards_LoadUI()
end
local noRunsYetMessage = '|cffff0000Pluslist: No runs completed yet this week|r'
local cbframe = CreateFrame('Frame', 'pluslist', UIParent)
cbframe:SetScript('OnEvent', function(self, event)
  if (event == 'CHALLENGE_MODE_MAPS_UPDATE') then
    local inclPrevWks = false
    local inclIncompleteRuns = true
    local runInfo = C_MythicPlus.GetRunHistory(inclPrevWks, inclIncompleteRuns)
    self.fn(pluslist_pairsByLevel(runInfo))
    self:UnregisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
  end
end)

function pluslist_pairsByLevel(t)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, function(x, y)
    return t[x].level == t[y].level
      and t[y].mapChallengeModeID > t[x].mapChallengeModeID
      or t[y].level < t[x].level
  end)

  local i = 0
  local iter = function()
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end

  return iter
end

function pluslist_colorByRank(rank)
  local epic, rare, uncommon = '|cffa335ee', '|cff0070dd', '|cff1eff00'
  local colors = { [1] = epic, [4] = rare, [10] = uncommon }
  return colors[rank] or ''
end

function pluslist_verbose(runInfo)
  local rewards = {
    [2] = 200,  [3] = 203,  [4] = 207,
    [5] = 210,  [6] = 210,  [7] = 213,
    [8] = 216,  [9] = 216, [10] = 220,
   [11] = 220, [12] = 223, [13] = 223,
   [14] = 226, [15] = 226
  }
  local i = 1
  for _,run in runInfo do
    local color = pluslist_colorByRank(i)
    local reward = rewards[math.min(run.level, 15)]
    local s = string.format('%s%d: +%d %s (%d)|r', color, i, run.level,
      C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID), reward)
    DEFAULT_CHAT_FRAME:AddMessage(s)
    i = i + 1
    if (i > 10) then break end
  end
  if (i == 1) then
    DEFAULT_CHAT_FRAME:AddMessage(noRunsYetMessage)
  end
end

function pluslist_brief(runInfo)
  local i = 1
  local s = { [1] = noRunsYetMessage }
  for _,run in runInfo do
    local color = pluslist_colorByRank(i)
    s[i] = string.format('%s+%d|r', color, run.level)
    i = i + 1
    if (i > 10) then break end
  end
  DEFAULT_CHAT_FRAME:AddMessage(table.concat(s, ', '))
end

function CreateChatCommandHandler(fn)
  return function(msg, editbox)
    cbframe:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
    cbframe.fn = fn
    C_MythicPlus.RequestRewards()
  end
end

SlashCmdList.PLUSLISTVERBOSE = CreateChatCommandHandler(pluslist_verbose)
SlashCmdList.PLUSLISTBRIEF   = CreateChatCommandHandler(pluslist_brief)

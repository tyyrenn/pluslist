SLASH_PLUSLISTVERBOSE1 = '/pluslist'
SLASH_PLUSLISTBRIEF1 = '/pl'

local MAX_RUNS_FOR_VAULT = 8
local noRunsYetMessage = '|cffff0000Pluslist: No runs completed yet this week|r'
local cbframe = CreateFrame('Frame', 'pluslist', UIParent)
local lastupdate = nil
cbframe:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
cbframe:SetScript('OnEvent', function(self, event)
  if (event == 'CHALLENGE_MODE_MAPS_UPDATE') then
    lastupdate = time()
    if (self.fn ~= nil) then
      pluslist_fetchRewards(self.fn)
      self.fn = nil
    end
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
  local colors = { [1] = epic, [4] = rare, [8] = uncommon }
  return colors[rank] or ''
end

function pluslist_fetchRewards(projection)
  local inclPrevWks = false
  local inclIncompleteRuns = true
  local runInfo = C_MythicPlus.GetRunHistory(inclPrevWks, inclIncompleteRuns)
  projection(pluslist_pairsByLevel(runInfo))
end

function pluslist_verbose(runInfo)
  local i = 1
  for _,run in runInfo do
    local color = pluslist_colorByRank(i)
    local reward = C_MythicPlus.GetRewardLevelForDifficultyLevel(run.level)
    local s = string.format('%s%d: +%d %s (%d)|r', color, i, run.level,
      C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID), reward)
    DEFAULT_CHAT_FRAME:AddMessage(s)
    i = i + 1
    if (i > MAX_RUNS_FOR_VAULT) then break end
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
    if (i > MAX_RUNS_FOR_VAULT) then break end
  end
  DEFAULT_CHAT_FRAME:AddMessage(table.concat(s, ', '))
end

function CreateChatCommandHandler(fn)
  return function(msg, editbox)
    if time() - (lastupdate or 0) > 30 then
      cbframe.fn = fn
      C_MythicPlus.RequestMapInfo()
      C_MythicPlus.RequestRewards()
    else
      pluslist_fetchRewards(fn)
    end
  end
end

BINDING_HEADER_PLUSLIST = 'Pluslist'
BINDING_NAME_PLUSLISTDJTOGGLE = "Toggle Dungeon Journal"
BINDING_NAME_PLUSLISTGVTOGGLE = "Toggle Great Vault"

SlashCmdList.PLUSLISTVERBOSE = CreateChatCommandHandler(pluslist_verbose)
SlashCmdList.PLUSLISTBRIEF   = CreateChatCommandHandler(pluslist_brief)

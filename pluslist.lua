SLASH_PLUSLISTVERBOSE1 = '/pluslist'
SLASH_PLUSLISTBRIEF1 = '/pl'

function pluslist_pairsByLevel(t)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, function(x, y) return t[y].level < t[x].level end)

  local i = 0
  local iter = function()
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end

  return iter
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
    local color = ''
    local reward = rewards[run.level]
    if (i == 1 or i == 4 or i == 10) then color = '|cff00ff00' end
    local s = string.format('%s%d: +%d %s (%d)|r', color, i, run.level,
      C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID), reward)
    DEFAULT_CHAT_FRAME:AddMessage(s)
    i = i + 1
    if (i > 10) then break end
  end
end

function pluslist_brief(runInfo)
  local i = 1
  local s = ''
  for _,run in runInfo do
    local color = ''
    if (s ~= '') then s = s .. ', ' end
    if (i == 1 or i == 4 or i == 10) then color = '|cff00ff00' end
    s = s .. string.format('%s+%d|r', color, run.level)
    i = i + 1
  end
  DEFAULT_CHAT_FRAME:AddMessage(s)
end

function CreateChatCommandHandler(fn)
  return function(msg, editbox)
    local inclPrevWks = false
    local inclIncompleteRuns = true
    local runInfo = C_MythicPlus.GetRunHistory(inclPrevWks, inclIncompleteRuns)

    fn(pluslist_pairsByLevel(runInfo))
  end
end

SlashCmdList.PLUSLISTVERBOSE = CreateChatCommandHandler(pluslist_verbose)
SlashCmdList.PLUSLISTBRIEF   = CreateChatCommandHandler(pluslist_brief)

getgenv().Settings = {
    ["Enabled"] = true,
    ["Message"] = "Hey I love your avatar, can I make some art of your avatar for 10? If so, soljns 6273 !",
    ["Type"] = "Whisper", -- Types - Whisper/All. Whisper will /w everyone then hop, all with spam the message a determined amount of times.
    ["Messages"] = 10, -- If type is set to all, otherwise
    ["Cooldown"] = 5, -- Cooldown between messages, recommend 2.5
    ["ServerHop"] = true
}

repeat task.wait() until game:IsLoaded()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Request = syn.request

local Settings = getgenv().Settings -- So I dont have to type getgenv() every time lol

if isfolder("Archer") then 
    if isfile("Archer/PrevServer.json") then
    else
        writefile("Archer/PrevServer.json", "")
    end
else
    makefolder("Archer")
    writefile("Archer/PrevServer.json", "")
end


function Say(Message)
    local Channel = "All"

    local remote = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
    remote:FireServer(tostring(Message), Channel)
end

local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) and tonumber(v.playing) > 10 then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end


if Settings["Type"]:lower() == "whisper" then
    for i,v in pairs(Players:GetChildren()) do
        if v ~= Players.LocalPlayer and Settings["Enabled"] then
            if v ~= nil and v:FindFirstChild("leaderstats") then
                if v.leaderstats:WaitForChild("Raised").Value > 500 or v.leaderstats:WaitForChild("Donated").Value > 500 then
                    Say("/w "..v.Name.." "..Settings["Message"])
                    task.wait(Settings["Cooldown"])
                end
            end
        end
    end
elseif Settings["Type"]:lower() == "all" then
    for i = 1, Settings["Messages"], 1 do
        if Settings["Enabled"] then
            Say("Message")
            task.wait(Settings["Cooldown"])
        end
    end
else
    warn("no set type lol")
end

Teleport()

--[[
 * ReaScript Name: transpose note under mouse cursor
 * Author: mccrabney
 * Licence: GPL v3
 * REAPER: 6.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2023-05-08)
   + requires extstates from mccrabney_MIDI edit - show notes, under mouse and last-received.lua
--]]

---------------------------------------------------------------------
extName = "mccrabney_MIDI edit - show notes, under mouse and last-received.lua"  

---------------------------------------------------------------------

function getNotesUnderMouseCursor()
  
  showNotes = {}
  tableSize = tonumber(reaper.GetExtState(extName, 1 ))
  guidString = reaper.GetExtState(extName, 2 )
  take = reaper.SNM_GetMediaItemTakeByGUID( 0, guidString )
  targetNoteNumber = tonumber(reaper.GetExtState(extName, 3 ))
  targetNoteIndex = tonumber(reaper.GetExtState(extName, 4 ))
  
  if tableSize ~= nil then 
    for t = 1, tableSize do
      showNotes[t] = {}
      if reaper.HasExtState(extName, t+4) then
        for i in string.gmatch(reaper.GetExtState(extName, t+4), "-?%d+,?") do
          table.insert(showNotes[t], tonumber(string.match(i, "-?%d+")))
        end
      end
    end
  end
  
  return take, targetNoteNumber, targetNoteIndex
end

---------------------------------------------------------------------

function main()
  reaper.PreventUIRefresh(1)
  
   _,_,_,_,_,_,mouse_scroll  = reaper.get_action_context() 
  if mouse_scroll > 0 then 
    incr = 1                            -- how many ticks to move noteoff forwards, adjust as desired
  elseif mouse_scroll < 0 then 
    incr = -1                          -- how many ticks to move noteoff backwards, adjust as desired
  end
    
  take, targetNoteNumber, targetNoteIndex = getNotesUnderMouseCursor()
  local pitchList = {"C_", "C#", "D_", "D#", "E_", "F_", "F#", "G_", "G#", "A_", "A#", "B_"}

  if take ~= nil and targetNoteIndex ~= -1 then
    _, _, _, _, _, _, pitch, _ = reaper.MIDI_GetNote( take, targetNoteIndex )
    
    pitch = pitch + incr
    if pitch > 127 then pitch = 127 end
    if pitch < 0 then pitch = 0 end  
    
    reaper.MIDI_SetNote( take, targetNoteIndex, nil, nil, nil, nil, nil, pitch, nil)
    reaper.MIDI_Sort(take)
    reaper.SetExtState(extName, 'DoRefresh', '1', false)
    
    octave = math.floor(targetNoteNumber/12)-1                               -- establish the octave for readout
    cursorNoteSymbol = pitchList[(targetNoteNumber - 12*(octave+1)+1)]       -- establish the note symbol for readout
    reaper.Undo_OnStateChange2(proj, "transposed " .. targetNoteNumber .. "(" .. cursorNoteSymbol .. octave .. ")" .. " to " .. targetNoteNumber+incr .. "(" .. cursorNoteSymbol .. octave .. ")")
  end
  
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()

end
 
main()

  

  
  

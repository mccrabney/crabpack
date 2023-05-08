--[[
 * ReaScript Name: Delete notes under mouse cursor, closest first
 * Author: mccrabney
 * Licence: GPL v3
 * REAPER: 6.0
 * Extensions: None
 * Version: 1.3
--]]
 
--[[
 * Changelog:
 
 * v1.3 (2023-5-07)
    + major simplification using extstate from 'mccrabney_MIDI edit - show notes, under mouse and last-received.lua'
 
 * v1.2 (2023-1-05)
   + removed errant console message
 
 * v1.1 (2023-01-02)
   + fix for multiple notes
   + if multiple notes exist equidistant from mouse cursor, delete highest first
   
 * v1.0 (2023-01-01)
   + Initial Release
--]]


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
  
  take, targetNoteNumber, targetNoteIndex = getNotesUnderMouseCursor()

  local pitchList = {"C_", "C#", "D_", "D#", "E_", "F_", "F#", "G_", "G#", "A_", "A#", "B_"}

  if take ~= nil and targetNoteIndex ~= -1 then
    reaper.MIDI_DeleteNote(take, targetNoteIndex)
    reaper.MIDI_Sort(take)
    
    reaper.SetExtState(extName, 'DoRefresh', '1', false)
    
    octave = math.floor(targetNoteNumber/12)-1                               -- establish the octave for readout
    cursorNoteSymbol = pitchList[(targetNoteNumber - 12*(octave+1)+1)]       -- establish the note symbol for readout
    reaper.Undo_OnStateChange2(proj, "deleted note " .. targetNoteNumber .. ", (" .. cursorNoteSymbol .. octave .. ")")
  end
  
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()

end
 
main()


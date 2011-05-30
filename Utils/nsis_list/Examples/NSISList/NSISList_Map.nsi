;-----------------------------------------------------------------------------------
; Map example of NSISList Plugin
;-----------------------------------------------------------------------------------

;Required include to use NSISList
!include NSISList.nsh

;Reserve the NSISList plugin
ReserveFile "${NSISDIR}\Plugins\NSISList.dll"
 
;set name and output file
Name "NSISList Map Example"
OutFile "NSISList_Map.exe"
 
;Show the log
ShowInstDetails show
 
Section
  DetailPrint "Creating map!"

  ; Create a map named "MyTestMap"
  ${Map.Create} MyTestMap
 
  ; Associate "Mouse" with "Small"
  ${Map.Set} MyTestMap "Mouse" "Small"

  ; Associate "Tree" with "Huge"
  ${Map.Set} MyTestMap "Tree" "Huge"
  
  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  ; Get value associated with "Tree"
  ${Map.Get} $0 MyTestMap "Tree"
  DetailPrint 'Value associated with "Tree" is: $0'

  ; Get value associated with "Mouse"
  ${Map.Get} $0 MyTestMap "Mouse"
  DetailPrint 'Value associated with "Mouse" is: $0'

  ; Get value associated with "Wallpaper"
  ${Map.Get} $0 MyTestMap "Wallpaper"
  DetailPrint 'Value associated with "Wallpaper" is: $0'
  
  ; Display some debug info
  ; ${List.Debug}

  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  DetailPrint "Modifying map!"

  ; Associate "Tree" with "Old"
  ${Map.Set} MyTestMap "Tree" "Old"

  ; Associate "Wallpaper" with "Green"
  ${Map.Set} MyTestMap "Wallpaper" "Green"

  ; Remove value associated with "Mouse"
  ${Map.Unset} MyTestMap "Mouse"

  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  ; Get value associated with "Tree"
  ${Map.Get} $0 MyTestMap "Tree"
  DetailPrint 'Value associated with "Tree" is: $0'

  ; Get value associated with "Mouse"
  ${Map.Get} $0 MyTestMap "Mouse"
  DetailPrint 'Value associated with "Mouse" is: $0'

  ; Get value associated with "Wallpaper"
  ${Map.Get} $0 MyTestMap "Wallpaper"
  DetailPrint 'Value associated with "Wallpaper" is: $0'
  
  ; Display some debug info
  ; ${List.Debug}

  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  DetailPrint "Save map to file now!"
  
  ; Save the map to file
  ${Map.Save} MyTestMap "$EXEDIR" "Map_Test"

  DetailPrint "Clear the map!"

  ; Remove all entries from the map!
  ; ${Map.Clear} MyTestMap
  
  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  ; Get value associated with "Tree"
  ${Map.Get} $0 MyTestMap "Tree"
  DetailPrint 'Value associated with "Tree" is: $0'

  ; Get value associated with "Mouse"
  ${Map.Get} $0 MyTestMap "Mouse"
  DetailPrint 'Value associated with "Mouse" is: $0'

  ; Get value associated with "Wallpaper"
  ${Map.Get} $0 MyTestMap "Wallpaper"
  DetailPrint 'Value associated with "Wallpaper" is: $0'
  
  ; Display some debug info
  ; ${List.Debug}
  
  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  DetailPrint "Destroy the map!"

  ; Destroy the map
  ${Map.Destroy} MyTestMap

  DetailPrint "Load new map from file!"

  ; Create a map named "MyTestMap"
  ${Map.Create} MyOtherMap

  ; Save the map to file
  ${Map.Load} MyOtherMap "$EXEDIR" "Map_Test"

  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  ; Get value associated with "Tree"
  ${Map.Get} $0 MyOtherMap "Tree"
  DetailPrint 'Value associated with "Tree" is: $0'

  ; Get value associated with "Mouse"
  ${Map.Get} $0 MyOtherMap "Mouse"
  DetailPrint 'Value associated with "Mouse" is: $0'

  ; Get value associated with "Wallpaper"
  ${Map.Get} $0 MyOtherMap "Wallpaper"
  DetailPrint 'Value associated with "Wallpaper" is: $0'
  
  ; Display some debug info
  ; ${List.Debug}

  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------

  DetailPrint "Unload!"

  ; Unload NSISList plugin
  ${List.Unload}

  ;-----------------------------------
  DetailPrint "----------------------"
  ;-----------------------------------
SectionEnd

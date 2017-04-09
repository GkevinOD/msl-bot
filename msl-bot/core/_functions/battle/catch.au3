#cs ----------------------------------------------------------------------------
 Function: catch
 Algorithm for catching a certain astromons

 Parameters:
	varImages - Set of images to search for specific astromons.
	boolLog - To log or not to log catches.
	boolCreateIMG - If not recognized, create image or not.
	boolOneAstromon - Stop after one astromon or not.

 Returns:
	String of type of astromon caught
	On astromon bag full - Returns -1
	On not tried - Returns -2

#ce ----------------------------------------------------------------------------

Func catch($varImages, $boolLog = True, $boolCreateIMG = True, $boolOneAstromon = False, $boolCheckTried = True, $boolCheckCaught = True)
	Local $strCaught = ""
	Local $strAstromonGrade = ""
	Local $boolTried = False

	While True
		While True
			If Not getLocation() = "catch-mode" Then Return ""
			If Not $boolTried Then setLogReplace("Locating astromon...", 1)

			If isArray($varImages) Then ;finding astromon within list
				Local $pointArray = findImages($varImages, 100, 3000, 0, 263, 800, 473)
			Else
				Local $pointArray = findImage($varImages, 100, 3000, 0, 263, 800, 473)
			EndIf
			If getLocation() = "battle-astromon-full" Then Return -1

			If isArray($pointArray) = True Then ;if found
				setLogReplace("Locating astromon... Found!", 1)
				$strAstromonGrade = _StringProper(StringRegExpReplace($pointArray[3], ".*catch-(.*)([0-9]\.|\.)bmp", "$1"))

				$boolTried = True ;indicate that catching was attempted
				clickUntil($pointArray, "battle", 200, 500)

				If getLocation() = "battle-astromon-full" Then Return -1
				If Not checkLocations("battle-end-exp, battle-sell, battle-end") = "" Then Return $strCaught

				If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
					$strCaught &= StringMid($strAstromonGrade, 1, 2)
					If $boolLog = True Then setLog("Astromon Caught: " & $strAstromonGrade & "!")
					If $boolOneAstromon Then Return $strCaught ;stops after one catch or no catch

					If $boolLog = True Then setLog("Checking for more astromons..", 1)
					navigate("battle", "catch-mode")
					ExitLoop ;going back to inner loop to check for more astromon
				Else
					If $boolCheckCaught = True Then
						If $boolLog = True Then setLog("Checking if caught...", 1)
						Local $startTimer = TimerInit()

						If IsArray(findImages($imagesRareAstromon, 100, 3000)) Then
							If $boolLog = True Then setLog("Out of astromon chips!", 1)
							If $boolLog = True Then setLog("Missed a " & $strAstromonGrade & ".", 1) ;if missed astromon
						Else
							$strCaught &= StringMid($strAstromonGrade, 1, 2)
							If $boolLog = True Then setLog("Astromon Caught: " & $strAstromonGrade & "!")
							If $boolOneAstromon Then Return $strCaught ;stops after one catch or no catch
						EndIf
					Else
						$strCaught &= StringMid($strAstromonGrade, 1, 2)
						If $boolLog = True Then setLog("Assumed to be Caught: " & $strAstromonGrade & "!")
						If $boolOneAstromon Then Return $strCaught ;stops after one catch or no catch
					EndIf

					Return $strCaught
				EndIf
			Else
				If ($boolCheckTried = True) And ($boolTried = False) Then ;if astromon was not recognized
					If $boolLog = True Then setLog("Could not recognize astromon.", 1)
					If $boolCreateIMG = True Then
						Local $tempInt = 0
						While(FileExists(@ScriptDir & "/NotRecognized" & $tempInt & ".bmp"))
							$tempInt += 1
						WEnd

						If $boolLog = True Then setLog("Saving to NotRecognized" & $tempInt & ".bmp", 1)
						_CaptureRegion("NotRecognized" & $tempInt & ".bmp", 0, 263, 800, 473)

						clickUntil($battle_coorCatchCancel, "battle")
					EndIf
					Return -2
				EndIf

				setLogReplace("Locating astromon... Not found.", 1)
				clickUntil($battle_coorCatchCancel, "battle")
			EndIf

			Return $strCaught
		WEnd
	WEnd
EndFunc
/*
__MXSDOC__

[TITLE]
UI_ViewportDisplayInfo.ms

[DESCRIPTION]
Display several customized information in the viewport. The user can select what he wants to display, like shot number, camera name, frame , etc ... 
very useful for making previews

[USAGE]
Run Script

[CREATION INFO]
Author: Blur Tool Teal
E-mail: blurbeta@blur.com
Company: Blur Studio
Last Updated: 11 Dec 2008

[KEYWORDS]
Scriber
Viewport
Info

[VERSION HISTORY]
-- 1.0 . created
-- 1.1 . Now the information is saved with the max file so we can create custom viewport info display per max file
--	   . now when you press shift to open the options it will always display the viewport info, before the options only appeared when you
--	   .  turned on the viewport display
-- 1.2 . added framesInCameraRange
-- 1.3 . added focal lens in mm, target distance

[TO DO]

[SEE ALSO]
Requested by: 
Tested using 3dsmax 7.0

__END__
*/

----------------------------------------------------------------------------------------------------------------------------------------------------
-- global variables
----------------------------------------------------------------------------------------------------------------------------------------------------
_blurLibrary.load "blurCamera"

global vdi_infoArray = #()

persistent global vdi_Text = if (vdi_Text != undefined) then vdi_Text else "" --"<shotNumber> frame:<frame> fps:<fps>"
global vdi_showBk		= true
global vdi_frColor 		= white
global vdi_bkColor 		= black
global vdi_pos 			= [5,0]
global vdi_on 			= false
global vdi_configFile 	= "$plugcfg/viewportDisplayInfo.ini"

-- get the info from the config file
if (doesfileexist vdi_configFile == false) then
(
	setIniSetting vdi_configFile "Configuration" "Text" 			vdi_Text
	setIniSetting vdi_configFile "Configuration" "TextColor" 		(vdi_frColor as string)
	setIniSetting vdi_configFile "Configuration" "BackGroundColor"  (vdi_bkColor as string)
	setIniSetting vdi_configFile "Configuration" "Position" 		(vdi_pos as string)
	setIniSetting vdi_configFile "Configuration" "enabled" 			(vdi_on as string)
	setIniSetting vdi_configFile "Configuration" "showBackGround" 	(vdi_showBk as string)	
)
else
(
	if (vdi_Text == undefined) then
		persistent global vdi_Text 	= getIniSetting vdi_configFile "Configuration" "Text"
		
	vdi_frColor = execute(getIniSetting vdi_configFile "Configuration" "TextColor")
	vdi_bkColor = execute(getIniSetting vdi_configFile "Configuration" "BackGroundColor")
	vdi_pos 	= execute(getIniSetting vdi_configFile "Configuration" "Position") 		
	vdi_on 		= execute(getIniSetting vdi_configFile "Configuration" "enabled")
	vdi_showBk	= try (execute(getIniSetting vdi_configFile "Configuration" "showBackGround")) catch (true)
	
)
----------------------------------------------------------------------------------------------------------------------------------------------------
--	Prototype: 
--		struct struct vdi_InfoStruct
--
--	Remarks:
--		used to store the information to be displayed in the viewport
--
--	variables:
--		id 			: this id will be used by vdi script to identify the different vdi plugins
--		description	: 
--		getText 	: all the vdi plugins should return a string of what they want to display in the viewport
--	methods
--		none
--	Dependencies:
--		none
----------------------------------------------------------------------------------------------------------------------------------------------------
struct vdi_InfoStruct
(
	id 		 		= ""
	,description	= ""
	,getText 		= ""
)

----------------------------------------------------------------------------------------------------------------------------------------------------
--	Prototype: 
--		fn vdi_PaintInfo
--
--	Remarks:
-- 		function that draws the text in the viewport
--	Parameters:
--		none
--	Return Value:
--		none
----------------------------------------------------------------------------------------------------------------------------------------------------
fn vdi_PaintInfo =
(
	local vpText = ""
	
	-- get the array of commands and create the text to display
	local commands = filterstring vdi_Text "<>"
	
	for c in commands do
	(
		local textToAdd = c
		
		-- gather the text from the commands
		for i in vdi_infoArray do
			if (c == i.id) then
				textToAdd = i.getText()
				
		vpText += textToAdd 
	)
	
	-- draws the information in the viewport
	local windowSize = [gw.getWinSizeX(), gw.getWinSizeY()]
	local sizeText   = GetTextExtent vpText 
	local vdi_posX 	 = vdi_pos.x * windowSize.x / 100.0
	local vdi_posY 	 = vdi_pos.y * windowSize.y / 100.0
	local textRect 	 = box2 0 (windowSize.y - vdi_posY - sizeText.y - 5) (windowSize.x) (sizeText.y + 7)

	gw.setTransform (matrix3 1)
	
	if (vdi_showBk == true) then
	(
		gw.setcolor #clear vdi_bkColor									-- vdi_bkColor
		gw.clearScreen textRect useBkg:false							-- rectangle containing the text
		gw.setcolor #clear (GetUIColor 41 * 255) 						-- viewport background color
	)
	else
	(
		textRect = box2 (vdi_posX) (windowSize.y - vdi_posY - sizeText.y - 5) (sizeText.x + 5) (sizeText.y + 7)
	)
	
	gw.htext [vdi_posX, vdi_posY , 100] vpText color: vdi_frColor 	-- draws the text in the viewport
	
	gw.enlargeUpdateRect textRect
	gw.updatescreen()
)

----------------------------------------------------------------------------------------------------------------------------------------------------
--	Prototype: 
--		fn vdi_ViewportCallback
--
--	Remarks:
-- 		This is the function used by the viewport callback
--	Parameters:
--		
--	Return Value:
--		
----------------------------------------------------------------------------------------------------------------------------------------------------
fn vdi_ViewportCallback = vdi_PaintInfo()





--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--	Rollout:
--		rollout vdi_Rollout  
--
--	Description:
--		Options for the vdi script
--
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
rollout vdi_Rollout "Viewport Display Info Options" width:455 height:105
(

	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- vdi_Rollout local variables
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local minSize = [455, 105]
	local lastSize = minSize 
	
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- vdi_Rollout uaser interface
	----------------------------------------------------------------------------------------------------------------------------------------------------
	colorPicker tcolorCpUI "" pos:[125,43] width:60 height:18 enabled:true
	label txtColLblUI "Text Color" pos:[72,45] width:55 height:16
	edittext textEdtUI "" pos:[10,16] width:427
	GroupBox grpUI "" pos:[6,2] width:438 height:95
	colorPicker tbkcolorCPUI "" pos:[125,68] width:60 height:18 color:(color 0 0 155)
	label lbl2 "Background Color" pos:[34,69] width:92 height:16
	spinner xposSpnUI "" pos:[209,43] width:72 height:16 range:[0,100,0] type:#float
	spinner yposSpnUI "" pos:[209,69] width:72 height:16 range:[0,100,0] type:#float
	label xposlblUI "X: " pos:[194,44] width:13 height:16
	label yposLBLUI "Y: " pos:[194,70] width:17 height:16
	button okBtnUI "OK" pos:[340,40] width:98 height:22
	button cancelBtnUI "Cancel" pos:[340,68] width:98 height:22
	button helpBtnUI "?" pos:[290,52] width:25 height:25
	checkbox bkcolorchkUI "" pos:[14,68] width:16 height:16
	
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- vdi_Rollout methods
	----------------------------------------------------------------------------------------------------------------------------------------------------
	on vdi_Rollout open do
	(
		textEdtUI.text 		= vdi_Text
		tcolorCpUI.color 	= vdi_frColor 
		tbkcolorCPUI.color	= vdi_bkColor
		xposSpnUI.value 	= vdi_pos.x
		yposSpnUI.value 	= vdi_pos.y
		bkcolorchkUI.state  = vdi_showBk
	)

	on cancelBtnUI pressed do
		destroyDialog vdi_Rollout
	
	on okBtnUI pressed do
	(
		setIniSetting vdi_configFile "Configuration" "Text" 			vdi_Text
		setIniSetting vdi_configFile "Configuration" "TextColor" 		(vdi_frColor as string)
		setIniSetting vdi_configFile "Configuration" "BackGroundColor"  (vdi_bkColor as string)
		setIniSetting vdi_configFile "Configuration" "Position" 		(vdi_pos as string)
		setIniSetting vdi_configFile "Configuration" "enabled" 			(vdi_on as string)	
		setIniSetting vdi_configFile "Configuration" "showBackGround" 	(vdi_showBk as string)	
		
		destroyDialog vdi_Rollout
	)

	on tcolorCpUI changed col do
	(
		vdi_frColor = col
		redrawviews()
	)

	on tbkcolorCPUI changed col do
	(
		vdi_bkColor = col
		redrawviews()
	)
	
	on xposSpnUI changed val do
	(
		vdi_pos.x = val
		redrawviews()
	)
	
	on yposSpnUI changed val do
	(
		vdi_pos.y = val
		redrawviews()
	)
	
	on textEdtUI changed txt do
	(
		persistent global vdi_Text = txt
		redrawviews()
	)	
	
	on bkcolorchkUI changed state do
	(
		vdi_showBk = state
		redrawviews()
	)
	
	on helpBtnUI pressed do
	(
		local helpInfo = newScript()
		
		format "------------------------------------------------------------------------------------------------------------\n" to:helpInfo 
		format "-- Viewport Display Info Legend\n" to:helpInfo 
		format "------------------------------------------------------------------------------------------------------------\n\n" to:helpInfo 
		for i in vdi_infoArray do
			format "\"<%>\" : %\n" i.id i.description to:helpInfo 
		format "\n-- Example:\n" to:helpInfo 
		format "-- <shotNumber> frame:<frame> fps:<fps>\n" to:helpInfo 
		format "------------------------------------------------------------------------------------------------------------\n\n" to:helpInfo 
	)
	
	on vdi_Rollout resized size do
	(
		if (size.x < minsize.x) then
		(
			size.x = minSize.x		
			vdi_Rollout.width = minSize.x
		)
		vdi_Rollout.height = minSize.y

		local incSize = size - lastSize
	
		textEdtUI.width += incSize.x
		grpUI.width += incSize.x
		cancelBtnUI.pos.x +=  incSize.x
		okBtnUI.pos.x +=  incSize.x
		lastSize = size
		
	)
)


----------------------------------------------------------------------------------------------------------------------------------------------------
-- vdi plugins , at the moment reside in the same file, in the future they could be independent and loaded from disc
----------------------------------------------------------------------------------------------------------------------------------------------------
(


	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- current frame 
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local frameInfo = vdi_InfoStruct()
	frameInfo.id = "frame"
	frameInfo.description = "Current Frame"
	frameInfo.getText = fn getText = ( return (slidertime.frame as integer) as string )
	append vdi_infoArray frameInfo 
	
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- frame percentaje 
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local percentFrameInfo = vdi_InfoStruct()
	percentFrameInfo.id = "percentFrame"
	percentFrameInfo.description = "Time percentaje of the current animation segment"
	percentFrameInfo.getText = fn getText = ( return (slidertime.normalized * 100.0) as string )
	append vdi_infoArray percentFrameInfo 	

	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- frames per second
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local framesPerSecondInfo = vdi_InfoStruct()
	framesPerSecondInfo.id = "fps"
	framesPerSecondInfo.description = "Frames per second"
	framesPerSecondInfo.getText = fn getText = ( framerate as string)
	append vdi_infoArray framesPerSecondInfo 

	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- camera name
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local cameraInfo = vdi_InfoStruct()
	cameraInfo.id = "camera"
	cameraInfo.description = "Name of the camera"
	cameraInfo.getText = fn getText = ( 
										local vType = viewport.getType()
											
										if (vType == #view_camera) then
										(
											local curCamera = viewport.GetCamera()
											if (curCamera != undefined) then
												return curCamera.name
										)
										else
											return (vType as string)
									  )
	append vdi_infoArray cameraInfo 

	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- max filename 
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local maxfilenameInfo = vdi_InfoStruct()
	maxfilenameInfo.id = "filename"
	maxfilenameInfo.description  = "Current Max filename"
	maxfilenameInfo.getText = fn getText = ( maxfilename as string)
	append vdi_infoArray maxfilenameInfo 

	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- max filename path
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local maxpathnameInfo = vdi_InfoStruct()
	maxpathnameInfo.id = "path"
	maxpathnameInfo.description  = "Path of the current Max filename"
	maxpathnameInfo.getText = fn getText = ( maxfilepath as string)
	append vdi_infoArray maxpathnameInfo 
	
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- shot number
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local shotNumberInfo = vdi_InfoStruct()
	shotNumberInfo.id = "shotNumber"
	shotNumberInfo.description  = "Number of the shot (requires naming convention complaint camera)"
	shotNumberInfo.getText = fn getText = ( 
												local activeCamera = viewport.getCamera()
												if (activeCamera == undefined) then
													return "####"
												if (_blurCamera.isShotCamera activeCamera == false) then
													return "####"
												if (_blurCamera.isValidCamera activeCamera == false) then
													_blurCamera.addCameraData activeCamera
												
												local sNumber = activeCamera.shot	
												--local sNumberStr = activeCamera.basename + "_" + (_blurString.padNumber numberInput:sNumber padInt:4 padDec:2)
												local sNumberStr = "S" + (_blurString.padNumber numberInput:sNumber padInt:4 padDec:2)
												
												return sNumberStr 
											)
	append vdi_infoArray shotNumberInfo	
											
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- camera range info
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local cameraRangeInfo = vdi_InfoStruct()
	cameraRangeInfo.id = "cameraRange"
	cameraRangeInfo.description  = "Animation range of the current camera (requires naming convention complaint camera)"
	cameraRangeInfo.getText = fn getText = ( 
												local activeCamera = viewport.getCamera()
												if (activeCamera == undefined) then
													return "####"
												if (_blurCamera.isShotCamera activeCamera == false) then
													return "####"
												if (_blurCamera.isValidCamera activeCamera == false) then
													_blurCamera.addCameraData activeCamera
												
												local cameraRangeStr = "[ " + (activeCamera.rangestart as string) + " - " + (activeCamera.rangeend as string) + "]"
												
												return cameraRangeStr 
											)											
	append vdi_infoArray cameraRangeInfo	
	
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- framesInCameraRange
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local framesInCameraRangeInfo = vdi_InfoStruct()
	framesInCameraRangeInfo.id = "framesInCameraRange"
	framesInCameraRangeInfo.description  = "Number of frames in the Camera animation range (requires naming convention complaint camera)"
	framesInCameraRangeInfo.getText = fn getText = ( 
												local activeCamera = viewport.getCamera()
												if (activeCamera == undefined) then
													return "####"
												if (_blurCamera.isShotCamera activeCamera == false) then
													return "####"
												if (_blurCamera.isValidCamera activeCamera == false) then
													_blurCamera.addCameraData activeCamera
												
												local cameraRangeStr = ((activeCamera.rangeend - activeCamera.rangestart) as string)
												
												return cameraRangeStr 
											)											
	append vdi_infoArray framesInCameraRangeInfo		
											
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- camera target distance
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local cameraTargetDistanceInfo = vdi_InfoStruct()
	cameraTargetDistanceInfo.id = "cameraTargetDistance"
	cameraTargetDistanceInfo.description = "Target Distance of the camera"
	cameraTargetDistanceInfo.getText = fn getText = ( 
										local vType = viewport.getType()
											
										if (vType == #view_camera) then
										(
											local curCamera = viewport.GetCamera()
											if (curCamera != undefined) then
											(
												if (curCamera.type == #free) then
													return (curCamera.baseObject.targetDistance as string)
												else if (curCamera.type == #target) then
													return (curCamera.targetDistance as string)
												else
													return "???????"
											)
										)
										else
											return "#######"
									  )
	append vdi_infoArray cameraTargetDistanceInfo 
	
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- camera focal lens in mm
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local cameraFocalLensInfo = vdi_InfoStruct()
	cameraFocalLensInfo.id = "cameraFocalLens"
	cameraFocalLensInfo.description = "Camera Focal Lens in mm"
	cameraFocalLensInfo.getText = fn getText = ( 
										local vType = viewport.getType()
											
										if (vType == #view_camera) then
										(
											local curCamera = viewport.GetCamera()
											if (curCamera != undefined) then
											(
												local hFOV = curCamera.fov
												return ((cameraFOV.FOVtoMM hFOV) as string)
											)
										)
										else
											return "#######"
									  )
	append vdi_infoArray cameraFocalLensInfo 
									  									  
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- objects selected
	----------------------------------------------------------------------------------------------------------------------------------------------------
	local objectsSelectedInfo = vdi_InfoStruct()
	objectsSelectedInfo.id = "objectsSelected"
	objectsSelectedInfo.description = "List of the object selected"
	objectsSelectedInfo.getText = fn getText = ( 	
													if (selection.count == 0) then
														return "< None >"
													
													local objSelNames = "( "
													for i in selection do objSelNames += (i.name + " , ")
													objSelNames[objSelNames.count-1] = ")"
													return objSelNames 
												)
	append vdi_infoArray objectsSelectedInfo	
)

----------------------------------------------------------------------------------------------------------------------------------------------------
-- show/hide the vdi information and the configuration panel
----------------------------------------------------------------------------------------------------------------------------------------------------

unregisterRedrawViewsCallback vdi_ViewportCallback
if ( vdi_on == false or keyboard.controlpressed == true) then
(
	unregisterRedrawViewsCallback vdi_ViewportCallback
	registerRedrawViewsCallback vdi_ViewportCallback
	redrawviews()
	
	if (keyboard.controlpressed == true) then
		createdialog  vdi_Rollout style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing )
	
	vdi_on = true
)
else
(
	fn vdi_PaintInfo = (  )
	unregisterRedrawViewsCallback vdi_ViewportCallback
	forcecompleteredraw()
	vdi_on = false
)
setIniSetting vdi_configFile "Configuration" "enabled" (vdi_on as string)

--if (keyboard.controlpressed == true and vdi_on == true) then



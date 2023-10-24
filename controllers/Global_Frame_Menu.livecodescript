script "Global | Frame | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Frame | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   if exists (displayView) is false then return empty
   --
   put the displayed_Object of displayView into browserView
   if exists (browserView) is false then return empty
   --
   return browserView
end menu_Target

getprop menu_CheckTarget [browserView]
   return exists (browserView)
end menu_CheckTarget

getprop stackStyle_Param [cameraView]
   put the stack_Style of cameraView into sStyle
   return sStyle
end stackStyle_Param

getprop stackStyle_Params [cameraView]
   put the stack_Styles of cameraView into sStyles
   return sStyles
end stackStyle_Params

getprop window_Param [someView]
   put the stack_Frame of someView into stackFrame
   return stackFrame
end window_Param

getprop window_Params
   return "frameless,palette,toplevel"
end window_Params

getprop checked_PresentationMode
   put camera_ListStackNames() into sNames
   put camera_CheckAllFrameless (sNames) into someBoolean
   return someBoolean
end checked_PresentationMode

getprop checked_SystemWindow [someView]
   put the system_Window of someView into someBoolean
   return someBoolean
end checked_SystemWindow

getprop checked_Resizable [mTarget]
   put the stack_Name of mTarget into stackName
   put the resizable of stack stackName into sBoolean
   return sBoolean
end checked_Resizable
   
getprop decorations_Params
   /*
   The decorations of a stack is one of the following:
   
   - "default"
   - empty
   - one or more of "title", "minimize", "maximize", "close", "menu", "system", "noShadow", and "metal", separated by commas
   - a WDEF identifier (on Mac OS or OS X systems)
   
   By default, the decorations property of newly created stacks is set to "default"  
   */
   
   return "default,empty,-,title,minimize,maximize,close,menu,system,noShadow,metal"
end decorations_Params


--> Global | Frame | Menu
-
on menu_Clone cameraView
   put the stack_Name of cameraView into stackNameToClone
   stack_Clone stackNameToClone
end menu_Clone

private on _
end _

on menu_StackStyle cameraView, sStyle
   -- set the stack_Frame of someView to frameStyle
   set the stack_Style of cameraView to sStyle
end menu_StackStyle

-- on menu_Window someView, frameStyle
   set the stack_Frame of someView to frameStyle
end menu_Window

-- on menu_SystemWindow someView
   put the system_Window of someView into someBoolean
   set the system_Window of someView to (not someBoolean)
end menu_SystemWindow

on menu_Decorations someView, someDeco
   put the stack_Name of someView into stackName
   --
   if someDeco is "empty" then
      set the decorations of stack stackName to empty
   else
      set the decorations of stack stackName to someDeco
   end if
end menu_Decorations

private on __
end __

on menu_EditLabel someView
   put the stack_Label of someView into oldLabel
   --
   put lcw_Ask ("Edit the lable of this camera view...", oldLabel) into newLabel
   --
   set the stack_Label of someView to newLabel
end menu_EditLabel

on menu_Resizable mTarget
   put the stack_Name of mTarget into stackName
   put the resizable of stack stackName into sBoolean
   set the resizable of stack stackName to (sBoolean is false)
end menu_Resizable

private on __
end __

on menu_CreateTransparentMask someView
   breakpoint
   put the card_Object of someView into cardObject
   put the stack_Name of someView into stackName
   put the id of img _mask into maskID
   
   put the rect of someView into viewRect
   
   set backPattern of cardObject to ""
   --
   export snapshot from rect viewRect of someViewn to imgObject as PNG
   --
   set backPattern of cardObject to maskID
   set windowshape of stack stackName to maskID
   
   if "Mac" is in platform() then set shadow of stack stackName to false
end menu_CreateTransparentMask

on menu_SaveAndClose someView
   put the stack_Name of someView into stackName
   get the effective filename of stack stackName
   if it is not empty then
      lcw_Answer "Would you like to save this stack before closing?", someView
      save stack stackName
   end if
   --
   put "delete stack" && kwote (stackName) into pigoen
   send pigoen to someView in 2 ticks
end menu_SaveAndClose

script "Global | Frame | Menu"
--> MetaData
-
copyright: Anonymous
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

getprop frame_Param [someView]
   put the stack_Frame of someView into stackFrame
   return stackFrame
end frame_Param

getprop frame_Params
   return "frameless,palette,toplevel"
end frame_Params

getprop checked_PresentationMode
   put camera_ListStackNames() into sNames
   put camera_CheckAllFrameless (sNames) into someBoolean
   return someBoolean
end checked_PresentationMode

getprop checked_SystemWindow [someView]
   put the system_Window of someView into someBoolean
   return someBoolean
end checked_SystemWindow


--> Global | Frame | Menu
-
on menu_Clone someView
   put the stack_Label of someView into stackName
   if cameraName is empty then put the stack_Name of someView into stackName
   put lcw_Ask ("Give the new camera a name...", stackName) into newStackName
   --
   put the stack_Name of someView into stackNameToClone
   stack_Clone stackNameToClone, newStackName
   put the result into clonedStack
end menu_Clone

on _
end _

on menu_Frame someView, frameStyle
   set the stack_Frame of someView to frameStyle
end menu_Frame

on menu_SystemWindow someView
   put the system_Window of someView into someBoolean
   set the system_Window of someView to (not someBoolean)
end menu_SystemWindow

on menu_EditLabel someView
   put the stack_Label of someView into oldLabel
   --
   put lcw_Ask ("Edit the lable of this camera view...", oldLabel) into newLabel
   --
   set the stack_Label of someView to newLabel
end menu_EditLabel

on _
end _

on menu_Close someView
   put the stack_Name of someView into stackName
   get the effective filename of stack stackName
   if it is not empty then
      lcw_Answer "Would you like to save this stack before closing?", someView
      save stack stackName
   end if
   --
   put "delete stack" && kwote (stackName) into pigoen
   send pigoen to someView in 2 ticks
end menu_Close

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Clone someView
   put the stack_Name of someView into stackName
   stack_Clone stackName
   put it into clonedStack
end menu_Clone

on _
end _

on menu_Resizable someView, someBoolean
   put the stack_Name of someView into stackName
   set the resizable of stack stackName to someBoolean
end menu_Resizable

on menu_Decorations someView, someDeco
   /*
   The decorations of a stack is one of the following:
   
   - "default"
   - empty
   - one or more of "title", "minimize", "maximize", "close", "menu", "system", "noShadow", and "metal", separated by commas
   - a WDEF identifier (on Mac OS or OS X systems)
   
   By default, the decorations property of newly created stacks is set to "default"  
   */
   
   put the stack_Name of someView into stackName
   --
   if someDeco is "empty" then
      set the decorations of stack stackName to empty
   else
      set the decorations of stack stackName to someDeco
   end if
end menu_Decorations

on menu_Toplevel someView
   put the stack_Name of someView into stackName
   toplevel stack stackName
end menu_Toplevel



-- notif.applescript
-- macOS Notification Center controller - consolidated single file

-- ============================================================================
-- Constants
-- ============================================================================

property PROCESS_NAME : "NotificationCenter"
property SUBROLE_ALERT : "AXNotificationCenterAlert"
property SUBROLE_STACK : "AXNotificationCenterAlertStack"
property ACTION_CLOSE : "Close"

-- ============================================================================
-- Common Handlers
-- ============================================================================

-- Get NotificationCenter window
on getNotificationWindow()
	tell application "System Events"
		tell process PROCESS_NAME
			if (count of windows) = 0 then
				return missing value
			end if
			return window 1
		end tell
	end tell
end getNotificationWindow

-- Get first notification element (assumes already expanded)
-- Returns {notification:element, error:string}
on getFirstNotification(theWindow)
	tell application "System Events"
		tell process PROCESS_NAME
			set allElements to entire contents of theWindow
			
			repeat with element in allElements
				try
					if subrole of element is SUBROLE_ALERT then
						return {notification:element, errorMsg:""}
					end if
				end try
			end repeat
			
			return {notification:missing value, errorMsg:"No notifications"}
		end tell
	end tell
end getFirstNotification

-- Click element by subrole (for expand/collapse)
on clickElementBySubrole(theWindow, targetSubrole)
	tell application "System Events"
		tell process PROCESS_NAME
			set allElements to entire contents of theWindow
			
			repeat with element in allElements
				try
					if subrole of element is targetSubrole then
						click element
						return true
					end if
				end try
			end repeat
			
			return false
		end tell
	end tell
end clickElementBySubrole

-- Perform close action on a notification
on performCloseAction(notification)
	tell application "System Events"
		tell process PROCESS_NAME
		set actionList to actions of notification
		repeat with theAction in actionList
			if name of theAction contains ACTION_CLOSE then
				perform theAction
				return true
			end if
		end repeat
			return false
		end tell
	end tell
end performCloseAction

-- Check if notifications are in expanded state
on isExpanded(theWindow)
	tell application "System Events"
		tell process PROCESS_NAME
			set allElements to entire contents of theWindow
			
			repeat with element in allElements
				try
					if subrole of element is SUBROLE_ALERT then
						return true
					end if
				end try
			end repeat
			
			return false
		end tell
	end tell
end isExpanded

-- ============================================================================
-- Command Handlers
-- ============================================================================

-- Expand notification stack
on handleExpand()
	set theWindow to my getNotificationWindow()
	if theWindow is missing value then
		return "No notifications"
	end if
	
	-- 既に展開されていればスキップ
	if my isExpanded(theWindow) then
		return "Already expanded"
	end if
	
	set wasExpanded to my clickElementBySubrole(theWindow, SUBROLE_STACK)
	
	if not wasExpanded then
		return "No notification stack found"
	end if
	
	return "Expanded notification stack"
end handleExpand

-- Collapse notification stack
on handleCollapse()
	set theWindow to my getNotificationWindow()
	if theWindow is missing value then
		return "No notifications"
	end if
	
	-- 展開されていなければスキップ
	if not my isExpanded(theWindow) then
		return "Already collapsed or no notifications"
	end if
	
	tell application "System Events"
		tell process PROCESS_NAME
			set allElements to entire contents of theWindow
			
			-- Find and click the first non-alert button to collapse
			repeat with element in allElements
				try
					if role of element is "AXButton" then
						if subrole of element is not SUBROLE_ALERT then
							click element
							return "Collapsed notification stack"
						end if
					end if
				end try
			end repeat
		end tell
	end tell
	
	return "Already collapsed or no notifications"
end handleCollapse

-- Click first notification
on handleClick()
	set theWindow to my getNotificationWindow()
	if theWindow is missing value then
		return "No notifications"
	end if
	
	set resultData to my getFirstNotification(theWindow)
	
	if errorMsg of resultData is not "" then
		return errorMsg of resultData
	end if
	
	tell application "System Events"
		tell process PROCESS_NAME
			click (notification of resultData)
		end tell
	end tell
	
	return "Clicked first notification"
end handleClick

-- Close first notification
on handleClose()
	set theWindow to my getNotificationWindow()
	if theWindow is missing value then
		return "No notifications"
	end if
	
	set resultData to my getFirstNotification(theWindow)
	
	if errorMsg of resultData is not "" then
		return errorMsg of resultData
	end if
	
	set success to my performCloseAction(notification of resultData)
	
	if success then
		return "Closed first notification"
	else
		return "Error: Close action not found"
	end if
end handleClose

-- Toggle between expand and collapse
on handleToggle()
	set theWindow to my getNotificationWindow()
	if theWindow is missing value then
		return "No notifications"
	end if
	
	if my isExpanded(theWindow) then
		return my handleCollapse()
	else
		return my handleExpand()
	end if
end handleToggle

-- ============================================================================
-- Entry Point
-- ============================================================================

on run argv
	if (count of argv) = 0 then
		return "Error: No command specified"
	end if
	
	set cmd to item 1 of argv
	
	if cmd is "expand" then
		return my handleExpand()
	else if cmd is "collapse" then
		return my handleCollapse()
	else if cmd is "toggle" then
		return my handleToggle()
	else if cmd is "click" then
		return my handleClick()
	else if cmd is "close" then
		return my handleClose()
	else
		return "Error: Unknown command '" & cmd & "'"
	end if
end run

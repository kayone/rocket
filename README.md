rocket
======

Autohotkey quick launcher

setup
=====

1. Clone this repo (or fork it first)
2. Install [AutoHotkey](http://www.autohotkey.com/)
3. Add a new Windows task
  * Open Task Scheduler
  * Create a basic task
  * Start on log in
  * Start a program
  * Choose AutoHotkey.exe from your install location
  * Set arguments = launchpad.ahk
  * Set start in = folder you cloned this in
4. Set task properties 
  * General/Run with highest privileges = ON
  * General/Configure for = your OS
  * Conditions/Start the task only if computer is on AC power = OFF


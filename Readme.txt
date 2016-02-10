Motus
End of Week 7

Kinetic Chainp
tooltips match psd

Trends
Adjust the tooltips color styles to match psd
Try to reduce height

remove description hardcoded

Kinetic Strength
Grid Lines
mlb avg next to each line
reduce width of bars

Snapshots
90 day back filter and get sessions
SubTag Filter Snapshots



General
Fix Firefox
comparison:visual - tool tips to float a little higher for IPAD

Heroku Setup
DNS



Extras
Faster Load - 90 days on load, 365 on chart
Error Handling
Persistable Filter
Download Data in Excel
Player View
Team overview: 2 More Awards are being added
Add Google Analytics
Player Comparison filters
Tagging Throws on Tagging Chart

Ben
Trunk Rotation Foot contact should be yType = 3




*** WINDOWS WEB BROWSERS ***

----IE 11 win 8.1-----------------------------

Bugs

Player Overview
	- Pie charts do not animate correctly on hover. they enlarge, but the pie slice does not pop out.
	- This is the same in Comparison View as well.

Kinetic Chain Timeline
	- Tool tips stay open after view change

Snap Shots
 	-All (Foot, Ball release, Max Excursion, Joint Kinetics)
		* Filter not in right place
		* Filter does not have correct down arrow
		* Images when selecting metric are too large

TRENDS
	- Check boxes at the top are bleeding into the div above it


Comparison
	- Before a player is selected, the text is bleeding out of the Div
	- VISUAL
		* player silhouette images bleed outside of their divs
		* Pie charts enlarge, but there is a z-index issue with the
		  chart that is enlarged being tucked below the other
		  non-focused charts. Best example is the Pie chart that is
                   on the chest, when enlarged will display user the Shoulder
		  pie chart.
		* This makes it difficult to see the pie slices on that side.
		* Maybe we can ng-if the other charts out when one chart
		  is in focus?


--IE11 win 8.1-------------------------------------

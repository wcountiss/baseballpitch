Motus
End of Week 7

General
Fix Firefox
comparison:visual - tool tips to float a little higher for IPAD

Heroku Setup
DNS



*** WINDOWS WEB BROWSERS ***

----IE 11 win 8.1-----------------------------

Bugs

Player Overview
	- Pie charts do not animate correctly on hover. they enlarge, but the pie slice does not pop out.
	- This is the same in Comparison View as well.

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

--end IE11 win 8.1------------------------------------



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


****************** Ben - Meeting - *************************
Feb 11th 2016

Bugs
Player should load if bookmarkedt

Player Roster
	*Wants the roster to be able to extend down further

Player Comparison
	*player comparison overview -
	- the ‘Calculating thing’ what is going on with that?
	it is a Race condition

Kinetic Chain Timeline
	*tooltip should have elite metric in it

Kinetic Chain Strength
	* compress the height the chart to fit on screen
	* MLB average line needs a little breathing room

SNAP SHOTS + Kinetic Chain Table
	* Sub filter, change to something more semantic
	Game = Inning then pitch type
	Longtoss = distance
	Bullpen = pitch type
	out of order
	Inning First
	then Pitch types

TRENDS
	-bolder line for the “0” line
	for Y type2 , X axis on the zero
	or Bold it in some way
	Safari - degrees is cut off on the left
	sub filters
		- Innings above pitch type

BEN’s Feedback Continues
	wants to use the 15 hours we have
	wants the 2 added awards
	team logo detection and placement in upper-right

	player comparison
		-visual
			*scale down the pie charts
			*Round the numbers
			* if negative number, show 0 not -0
			Math.round(-0.003)+0  is solution.
			*doesn’t like the UX for comparison
			*Back button to remove compared guy
			*Back button to get out of comparison
				-wants that back button to bring you
				back to the last State you were in

************** End Feb 11th Meeting ************************


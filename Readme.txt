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
team logo detection and placement in upper-right

Player Roster
  *Wants the roster to be able to extend down further

****************** Ben - Meeting - *************************
Feb 11th 2016


Player Comparison
	*player comparison overview -
	- the ‘Calculating thing’ what is going on with that?
	it is a Race condition


	player comparison
		-visual
			*Back button to get out of comparison
				-wants that back button to bring you
				back to the last State you were in

************** End Feb 11th Meeting ************************


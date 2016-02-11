Motus
End of Week 7

Kinetic Chainp
tooltips match psd

Trends
Adjust the tooltips color styles to match psd
Try to reduce height

Kinetic Strength
tooltips match psd

Snapshots
Dropdowns fit better on page

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


--end IE11 win 8.1-------------------------------------


--IE10 win 7-----------------------------------------
IE10 win 7
Bugs

HEADER
	- Nav layout is not aligning properly. ‘team overview’ sits above ‘player analysis’ instead of beside it.
	- the underline hover bar is too long when active.


PLAYER ANALYSIS
	-player overview overview-
		*appears that the the injected view, line 29 player.html, is bleeding outside of the parent div.
		*Side Icons float on top of everything individually
		*PIE charts are randomly responsive. Some don’t react to a hover at all.
		*Nested footer Icons, the stats to the right of the Icon don’t stack on top of one another, but instead align side bye side.

	-player overview trends -
		*div only extends as far as the chart instead of filling the full width.
	-player overview notes-
		* nonsensical layout that has columns and rows overlapping


	-Kinetic Chain Timeline-
		*div only extends as far as the chart instead of filling the full width.

	-Kinetic Chain Strength-
		* MLB average text is overlapped by the orange line
		* Some of that text overlaps other bars in the graph

	-Kinetic Chain Table-
		*div overextends and bleeds out of parent div
		*images for metric illustration is too large

	-SNAP SHOTS-
		* filter downarrow is not the orange one we created
		*filter does not rest on the right side.
		*images for the metrics are too large and bleed over


PLAYER COMPARISON
	* the Div does not fill the full inner width, only about 50%
	*nav menu is oddly stacked

	-player comparison overview-
		* the 2 comparison views are crunched too close together
		* text in the ‘add a player’ prints across both of the divs and does not respect its parent container.
		*the graphs bleed outside of their parent divs

	-player comparison visual-
		* player silhouettes overlap one another and bleed outside of their parent divs.

--end IE10 win 7--------------------------------------------------------

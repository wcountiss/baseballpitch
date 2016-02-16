Motus
End of Week 8
Heroku Setup
DNS

6) Max Excursion: Can you please change the name of “Excursion” to “Angles”? - 0 hours

IE 11 UI
IPad UI - d3 tip should be higher

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

Questions for Ben
1) Kinetic Chain Filter: Is it possible to add the tag filter to the Kinetic Chain pages, similar to all other pages in the app? This would be for the graph, bar chart, and table. - 6 hours
2) Carrot Color Logic: I noticed that sometimes the horizontal arrows are showing up as yellow. Within Range should always be green, so I’m guessing this needs to be fixed still. - clarify 
3) For all timing measures, can you please remove the (-), since it already says “ms before release”? - add the check in stats service to absolute the value - 1 hour work
4) Kinetic Chain Bicep: Can you please change the “Bicep” word in the names of “Bicep Speed” and “Bicep Timing” to “Upper Arm”? 
5) Kinetic Compressive: Can you please change the name of “Compressive Force” to “Distraction Force”? - Parse or not
7) Kinetic Chain Bicep Speed: Can you please remove the pop up for “Bicep Speed”? We just want to show Hip and Trunk Speed timing. - Do we add legend? 2 hour
8) Kinetic Chain Table Order: Can you please change the order to the following? - 3 hours
        - Hip Speed
        - Trunk Speed
        - Upper Arm Speed
        - Forearm Speed
        - Hip Speed Timing
        - Trunk Speed Timing
        - Upper Arm Timing
        - Forearm Timing
        - Foot Contact Timing
        - Pitch Time
9) Within Self Comparison: This is a big item, but got another request for adding this, as well as the data filter in the player comparison tool. Would be nice to get it in if there’s dev resources/time available. - 15 hours


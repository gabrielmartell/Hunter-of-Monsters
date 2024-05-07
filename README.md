# COMP4501 Project Prototype - Hunter of Monsters #

Students:
	```Kelvin Jeon 101087383```
	```Alex Davidson 101149335```
	```Nicholas Veselskiy 101192011```
	```Gabriel Martell 101191857```

REPORT:
	The project report is in the base directory of the project. Project Report_Hunter of Monsters.pdf

To Get our Assets:
	Because of the limits of gradescope our project assets are located at this google drive: https://drive.google.com/drive/folders/1RA1vdYZ7gD_DIHqsZ6kk52g0SKwSOSx3?usp=sharing 

	Downlaod all of these folders and put them in the base directory of the project. Should look like:
	COMP-4501-Project/normal_maps
	COMP-4501-Project/Icons
	COMP-4501-Project/models
	COMP-4501-Project/textures

HOW TO PLAY:
	The main game is implemented in the map.tcsn.

	CONTROLS:
	Left Click + Drag
		Select Units
	Right Click (After Unit Selection)
		Default Action, if no target then move to the given position
		- If target is a resource then GRU units will harvest
		- If target is friendly then repair/heal
		- If target is an enemy then attack
		- Right click adds patrol points if patrol mode is toggled on
	Right Click (Building Selection)
		Cancel build selection
	B, C, T
		One Key Click:
			Highlight of building blueprint, determine placement
		Second Key Click:
			Confirm placement, and order GRU units to build Base, Camp and Trap respective to the key pressed. 
	H, G
		Produce Hunter or GRU units respectively.
	P (After Unit Selection)
		One Key Click; Toggle On:
			See Right Click Controls
		Second Key Click; Toggle Off:
			If patrol points are appended to unit, has unit patrol those selected points
	ESC
		Exit the game.

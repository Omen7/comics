# comics.*
### Overview
---

Simple comic engine for Corona SDK. Requires spine for loading frame animations.

### Functions
---

- comics.*new(**options, onComplete**)*
    - Will create a new comic. Constructor *requires* an **options** table and can accept an optional **onComplete** function that executes after the comic is closed. Options can be the following:
        - **animationSpeed.** An *optional number value* denoting the default animation speed for the spines. Default value is *10.*
		- **particlePath.** An *optional string value* containing the path to where the particles are being stored. The path should end with a trailing slash. If the engine tries to load a particle but there's no particlePath it will log an error.
        - **skin.** A *mandatory string value* denoting the skin name of the spine. This value is constant across the board.
        - **frames.** A *mandatory table* containing the data for each of the comic's frames. At least one frame of data should be contained within the table. **frames** receives the following parameters:
            - **spine.** A *mandatory string value* containing the path for the spine.json file.
            - **useAtlas.** A *mandatory string value* containing the path for the .atlas file.
            - **animation.** A *mandatory string value* containing the name of the spine's animation.
            - **loop.** An *optional boolean value* denoting wether the frame's animation should loop. Default value is *false.*
            - **time.** An *optional number value* denoting the time each frame should be displayed before moving on to the next. Default value is *2000ms*.
            - **x.** An *optional number value* in pixels denoting the frame's offset in the x-axis from the center of the screen. Default value is *0*.
            - **y.** An *optional number value* in pixels denoting the frame's offset in the y-axis from the center of the screen. Default value is *0*.
        - **okayButton** and **retryButton.** An *optional table* that can receive either the constructor for the **okayButton** and the **retryButton**, or individual offsets in the x-axis and y-axis from the cente of the last frame. If no constructor is received, default images will be used.
        - **soundTapID.** An *optional string value* denoting the sound ID that will be played whenever the comic is tapped and another frame loaded.
        - **soundButtonTapID.** An *optional string value* denoting the sound ID that will be played whenever one of the buttons of the comic is tapped.
    - An example of a full constructor can be found on the *main.lua* file included on the root of this project.
    - **WARNING: THE COMIC IS A DYNAMIC OBJECT. THEREFORE, IT SHOULD ALWAYS BE REMOVED.**

- comics:*play()*
    - Starts the comic animation.

### Usage
---

General considerations for using particle or sound events are as follows.
* **For particles:** If they're going to be used on a loopable frame, make sure a DESPAWN even is triggered at the end of each animation.
* **For sounds:** Sound events shouldn't be triggered on loopable frames, otherwise user experience might be compromised.

### Installation
---
Make sure the reference to this repository is included on your *bower.json* file:
```sh
"comics":"git@github.com:Omen7/comics.git"
```
Install bower in the root of your project:
```sh
$ bower install
```
The comic engine should now be installed in your project.

### To-Do
---
:heavy_check_mark: ~~Improve spine implementation to allow them to trigger sounds and particles per frame.~~

---
Copyright (c) 2017, Sebastian Mercado.
All rights reserved.
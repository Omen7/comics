# comics.*
### Overview
---

Simple comic engine for Corona SDK. Requires spine for loading frame animations.

### Functions
---

- comics.*new(**options**, **onComplete**)*
    - Will create a new comic. Constructor *requires* an **options** table and can accept an optional **onComplete** function that executes after the comic is closed. Options can be the following:
        - **animationSpeed.** An *optional number value* denoting the default animation speed for the spines. This value is constant across the board.
        - **skin.** A *mandatory string value* denoting the skin name of the spine. This value is constant across the board.
        - **frames.** A *mandatory table* containing the data for each of the comic's frames. At least one frame of data should be contained within the table. **frames** receives the following parameters:
            - **spine.** A *mandatory string value* containing the path for the spine.json file.
            - **useAtlas.** A *mandatory string value* containing the path for the .atlas file.
            - **animation.** A *mandatory string value* containing the name of the spine's animation.
            - **loop.** An *optional boolean value* denoting wether the frame's animation should loop.
            - **time.** An *optional number value* denoting the time each frame should be displayed before moving on to the next. Default value is *2000ms*.
            - **x.** An *optional number value* in pixels denoting the frame's offset in the x-axis from the center of the screen. Default value is *0*.
            - **y.** An *optional number value* in pixels denoting the frame's offset in the y-axis from the center of the screen. Default value is *0*.
        - **okayButton** and **retryButton.** An *optional table* that can receive either the constructor for the **okayButton** and the **retryButton**, or individual offsets in the x-axis and y-axis from the cente of the last frame. If no constructor is received, default images will be used.
        - **soundTapID.** An *optional string value* denoting the sound ID that will be played whenever the comic is tapped and another frame loaded.
        - **soundButtonTapID.** An *optional string value* denoting the sound ID that will be played whenever one of the buttons of the comic is tapped.
    - An example of a full constructor can be found on the *main.lua* file included on the root of the project.
    - **WARNING: THE COMIC IS A DYNAMIC OBJECT. THEREFORE, IT SHOULD ALWAYS BE REMOVED.**

- comics:*play()*
    - Starts the comic animation.

### Installation
---
Make sure the reference to this repository is included on your *bower.json* file:
```sh
"comics":"git@github.com:Omen7/comics.git"
```
Install bower in the root of your project:
```sh
bower install
```
The comic engine should now be installed in your project.

---
Copyright (c) 2017, Sebastian Mercado.
All rights reserved.
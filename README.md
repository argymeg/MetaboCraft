# This is the PiMPCraft readme.

## More coming soon.

### The server side

#### Requirements:

* A recent computer with at least 2 GB of RAM
* A *nix OS (tested on macOS and Linux)**
* Outbound HTTP access on port 8080
* Java (version 8 **strongly** recommended)
* R
* GNU Screen
* curl

There are no concrete CPU or storage space requirements, however a fast CPU can have a significant effect on performance. The base installation takes up around 50 MB of disk space, however the Minecraft world files can increase in size rapidly with usage - do plan accordingly.

Four shell scripts are provided with the server:
* An installer script (*install.sh*)
* A launcher and stopper for the full PiMPCraft stack (*start.sh* and *stop.sh*, respectively)
* A maintenance script to clear the Minecraft world (*clearworld.sh*). It is recommended to run this script regularly.

It is also recommended to regularly clean the server cache, conveniently located under the *cache* directory. **At a minimum**, if the server is used by more than one person, user-uploaded data (identified by the XXX???!!! prefix) should be regularly cleaned.

The PiMPCraft stack is comprised of three distinct components: the [Spigot](https://www.spigotmc.org/) Minecraft server, with the [ScriptCraft](https://scriptcraftjs.org/) plugin installed, a [plumber](https://www.rplumber.io/) server and a [Shiny](https://shiny.rstudio.com/) server. Access to the Spigot console, as well as the logging output of the other two components, is provided via separate GNU Screen sessions.

### The client side

#### Requirements:
* A computer able to run [Minecraft](https://minecraft.net/)
* That's it!

#### User interface

The PiMPCraft landing page, which can be accessed using a web browser on port 32909 if the server is running on the local computer, provides an interface for uploading user data, as well as handy access to the PiMPCraft documentation.

To access the PiMPCraft world from Minecraft, after logging in, select *Multiplayer*, then *Add server*, select a name for the server and enter its address (which will be simply *localhost* if running on your local computer). Then select the server you just added and click *Join server*.

On joining the PiMPCraft server, you will be shown a welcome message informing you of the MetExplore Biosource you are currently viewing, as well as any files uploaded under your name. You will then given access to a map of the metabolic network, including switches to view the subset of the network corresponding to a particular cellular compartment. Selecting a node on this network, representing a specific pathway, will transport you to a view of this pathway. If you have previously uploaded a file of your own metabolomic data, this view will highlight the metabolites identified as changing.

A command line interface is provided via the Minecraft console (accessible by pressing / on the keyboard), which provides direct access to the above, as well as exposing some additional functionality.

Available commands are:

* `/jsp refresh`

Reinitialises the user's view of the PiMPCraft world, including reloading the list of uploaded files

* `/jsp buildMap <compartment name (optional)>`

Redraws the network map. If no compartment name is specified, it draws the entire network.

* `/jsp buildPath <pathway name>`

Draws a view of the specified pathway


* `/jsp chooseFile <filename>`

Allows choosing between different user-uploaded files for displaying changes in pathways. Leaving the filename blank will revert to a vanilla view of the network. Implies `/jsp refresh`. (???)

* `/jsp changeBioSource <id>`

Allows changing the BioSource to explore the metabolome of different organisms. This option is currently **experimental**. Applying user-provided data, in particular, is **not** expected to work properly beyond the default BioSource. Implies `/jsp refresh`.

### License

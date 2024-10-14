
# Architecture
This project is built with a [listen server](https://en.wikipedia.org/wiki/Game_server#Listen_server) architecture. A client acts as the server, and only the client-server has the authority to execute code remotely.
# Node Structure

```
root
├── Lobby
├── Globals
├── Signals
└──  Main
   ├── GameManager
   │   ├── PlayerSpawner
   │   ├── Players
   │   │  └── PlayerController
   │   │     ├── PlayerSynchronizer
   │   │     ├── InputSynchronizer
   │   │     ├── PlayerOrb
   │   │     └── PlayerUI
   │   └── MultiplayerTest
   │      ├── Environment
   │      ├── PlayerStartPositions
   │      └── Entities
   └── UI
       ├── DebugMenu
       └── LobbyUI
```

## Globals
`Lobby`, `Globals`, and `Signals`, are [autoload scripts](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html#doc-singletons-autoload) that are stored in `res://autoloads/`.
### Lobby
`Lobby` builds upon the example provided in the [official docs](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#example-lobby-implementation). The purpose of this project is to provide an example of how the Lobby code might be expanded upon.

The following notable changes were made:
- `_get_local_ip`: Returns the computer's current IP, depending on the platform. Useful for quick hosting and testing.
- `load_game`: This method has been changed to add scenes to the current scene tree, instead of replacing the whole scene tree. The arguments passed to this function in the `GameManager` script are all strings in order to limit the amount of data passed by the remote procedure call.\
  The `game_root_path` is used to select the node that will become the parent of the added level scene, namely `GameManager`.\
  The `packed_scene_root_node` is used to check whether the scene has already been loaded without having to instantiate the packed scene. This is achieved by getting the name of the root node from the packed scene resource with `str(scene_to_load.get_state().get_node_name(0))`.\
  Finally, the `packed_scene_resource_path` is used to load the resource.
- `player_loaded`: Uses the `players_loaded` array to keep track of all the client IDs that have been loaded and to ensure that each ID is only registered once, and checks whether the amount of connected players matches the amount of registered IDs.
### Globals
`Globals` keeps a reference of nodes that are useful to access anywhere in the codebase.
### Signals
`Signals` keeps track of all the [signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html#doc-signals) defined in the project.
## Node Hierarchy
### Main
`Main` serves as the project's entry point (the main scene) and is stored in the root directory, `res://main.tscn`.

It is used to instantiate and save a reference to the root nodes for the game scenes (`GameManager`) and general user interface scenes (`UI`).
### GameManager
`GameManager` is the root node for all the game scenes in the project and is stored in `res://scenes/game_manager.tscn`.

The level and player scenes are stored in the [`@export`](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-annotation-export) variables `level_to_load` and `player_scene` respectively.

The `_ready` function is used to connect to the [multiplayer signals](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#managing-connections) for managing player connections and level loading, and to store a reference to the `Players` node.

Player scenes are instantiated under the `Players` node when the game is started, and the [`PlayerSpawner`](https://docs.godotengine.org/en/stable/classes/class_multiplayerspawner.html) ensures that the instantiated player nodes are replicated across all clients.

> [!NOTE]
> The `PlayerOrb` in the player scene is disabled by default. Physics processing is only applied to it after the level is loaded and the game begins.

### MultiplayerTest
`MultiplayerTest` is the level scene loaded for this project and is stored in `res://scenes/levels/multiplayer_test.tscn`.

In the `_ready` function, the `Lobby.player_loaded` [remote procedure call (rpc)](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-annotation-rpc)  notifies the server that the level has been loaded on a client.

In the `_process` function, the `position_players` rpc moves the player nodes to their starting positions.\
In the `if` statement, `Lobby.players_loaded == Lobby.players_connected.size()` checks whether the amount of players that have loaded the level is equal to the number of players connected to the game.\
Because the code is placed in the [`_process`](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html) function, the `players_moved == false` check is added to ensure that the statements are only executed once.\
Finally, `position_players()` calls the function on the client that is hosting the game, while `position_players.rpc()` calls the function on all the clients connected remotely.

The `position_players` rpc receives the `@rpc("authority", "reliable")` annotation to ensure that only the network authority (the server) can execute it and that the call arrives at all clients reliably.\
A reference to the player nodes that were created when each player joined is collected with `Globals.players_spawn.get_children()`, and the spawn points for each player is collected from the `PlayerStartPositions` with `$PlayerStartPositions.get_children()`.\
If the amount of player nodes match the amount of players connected to the game, each player is moved to a starting position, defined by the `Marker3D` nodes under `PlayerStartPositions`.\
The global transform of each `Marker3D` is used in order to set each player's starting orientation.

>[!CAUTION]
>In order to safely move a `RigidBody3D`,
>- `set_physics_process` is changed to `false`,
>- its velocity is set to `0`,
>- the move operation is performed,
>- and only on the next physics frame is `set_physics_process` re-enabled.
>
>Because the `PlayerOrb` is disabled by default, the extra checks for `set_process_mode` are also included.

The `Entities` node is currently not utilized, but would be used to spawn in and manage other entities and projectiles during gameplay.
### PlayerController
`PlayerController` is the player scene and is stored in `res://scenes/player/player_controller.tscn`. It's responsible for managing the player nodes and setting authority.

The `multiplayer_id` variable has a [`setter`](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#static-variables) function that triggers whenever the variable is changed. It does the following:
- It updates the value of the variable with `multiplayer_id = id`.
- It renames the `PlayerController` root node to `multiplayer_id` with `self.name = str(id)`.
- Finally, it changes the [`InputSynchronizer`](https://docs.godotengine.org/en/stable/classes/class_multiplayersynchronizer.html) node's authority from server authority to client authority, giving the client control of the node in order to process the client's inputs.

>[!NOTE]
>When a child node's authority is changed, the parent node's authority also changes. When the `InputSynchronizer` node's authority is changed to `multiplayer_id`, the `PlayerController` node's authority is also set to `multiplayer_id`.

The `mulitplayer_info` variable stores player information, like name, number, color, etc, in a dictionary.

The `orb` variable stores a reference to the `PlayerOrb` node for easy access.

In the `_ready` function, the `if` statement checks whether the client has authority over the `PlayerController` and if they do, makes their instance of the `Camera3D` node active. This ensures that each player views the game world from their own camera's perspective.
### MultiplayerSynchronizer
The `PlayerSynchronizer` and `InputSynchronizer` are responsible for syncing player information and capturing player input respectively.
Selecting each of these nodes and navigating to the `Replication` tab at the bottom of the editor will list the properties synced by each.

>[!IMPORTANT]
>`MultiplayerSynchronizer` nodes should be kept at the top of the node hierarchy, just below their immediate parent.

The `InputSynchronizer` node is set to client authority in order to receive player inputs. Player inputs are processed and stored in the `input_direction` variable, which is then adjusted to remain relative to the camera direction. The adjusted values stored in the `camera_direction` variable.

In the `_ready` function, the `if` statement ensures that only the local client's `_process` and `_physics_process` loops are enabled.

The `_unhandled_input` function is used to capture player inputs.\
Mouse movement is used to rotate the `SpringArm3D` node around the `PlayerOrb`, by adjusting the rotation whenever an `InputEventMouseMotion` event is detected.\
When the `"ui_accept"` key is pressed, the `jump` function is called.\
With the `@rpc("authority)` annotation, a client sends a request to execute the function to the server. The server executes the jump for the client and synchronizes the results back to all clients.\
Because of the client-server setup however, the function also needs to be executed locally whenever the hosting client wants to jump.

>[!Note]
>The client hosting the game will always have a [`MultiplayerPeer`](https://docs.godotengine.org/en/stable/classes/class_multiplayerpeer.html) ID of `1`.

The `align_input_to_player_orientation` function adjusts the player's inputs to account for any rotation applied during the setup and positioning of the node.
### PlayerOrb
The `PlayerOrb` is a `CharacterBody3D` node that processes a player's movement. It is visually represented by the sphere `MeshInstance3D` that each player moves around in the level scene. It's also worth noting that the node is controlled by the server, it has server authority.

The `mesh_color` variable has a `setter` function that updates the variable's value and changes the `PlayerOrb`'s `MeshInstance3D`'s color with `$MeshInstance3D.mesh.material.albedo_color = color`. Its value is synchronized by the `MultiplayerSynchronizer` of the `PlayerOrb`.

The `do_jump` variable keeps track of whether a player has pressed the jump key. It is synchronized by the `PlayerSynchronizer` node. Whenever the `@rpc("authority") jump()` function is called in `InputSynchronizer`, its value is changed.\
In the `_apply_movement` function it is used to check whether the player has pressed jump and is on the floor before applying the jump velocity.

In the `_physics_process` function, `if multiplayer.is_server():` ensures that only the server processes physics for the `PlayerOrb`.

The `_apply_movement` function applies gravity if the `PlayerOrb` is not on the floor and processes jumps when the `do_jump` variable is set to `true` and the `PlayerOrb` is on the floor.\
The `dir` variable is used to calculate the velocity of the `PlayerOrb`. It's value is determined by the `camera_direction` variable in the `InputSynchronizer`, which is controlled by the client and receives player inputs.
### UI
`UI` is the root node for all general user interface scenes.
### DebugMenu
The `DebugMenu` is used to create and join a multiplayer session and load a level.\
The hosting player's IP is automatically set for Windows and Linux platforms with the `_get_local_ip` function in the `Lobby` autoload script. Joining clients use the same IP for testing, but would need to get the actual host's IP when the build is deployed.\
Depending on whether a session is created or joined, the player's name is also changed to "Host" or "Client" respectively.\
Finally, the `JoinButton` is disabled when the `HostButton` is pressed and, the `DebugMenu` is hidden when either the `JoinButton` or `LoadButton` is pressed.
### LobbyUI
The `LobbyUI` is used to display all the clients connected to the multiplayer session, along with details such as their `MultiplayerPeer` ID, color, and name.\
It connects to the `add_player_to_lobby_ui` signal that is emitted from the `add_player` function in the `GameManager` and the `player_disconnected` signal from the `MultiplayerAPI`.

The `_on_add_player_to_lobby` function is executed when a player joins the multiplayer session.
It first ensures that the function is only run on the server and that the joining client hasn't already been added to the `LobbyUI` node. Then it checks whether the ID received is in the `Lobby`'s `players_connected` dictionary, before creating a lobby element and setting up all the details.

The `_on_player_disconnected` function gets the lobby element node for the player that has disconnected and removes it from the scene tree.
### PlayerLobbyElement
The `PlayerLobbyElement` scene is a collection of `setter` functions that update the values for the `player_color`, `multiplayer_id`, and `player_name` variables and sets the values for the corresponding `ColorRect`'s color and `Label`'s text fields.
### MultiplayerDebugInfo
The `MultiplayerDebugInfo` scene currently just displays the `MultiplayerPeer` ID for the local client.

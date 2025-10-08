# C-Unity.nvim

Tired of switching between Unity and Neovim? This plugin aims to streamline your C# development workflow in Unity by bringing Unity logs and compilation commands directly into Neovim.

## Features

-   **Connect to Unity:** Establish a connection with the Unity Editor.
-   **View Unity Logs:** View logs from Unity in a floating window inside Neovim.
-   **Syntax Highlighting:** Custom syntax highlighting for Unity logs, with support for warnings and errors.
-   **Recompile Command:** Send a recompile command to Unity directly from Neovim.

## Installation

You can install this plugin using your favorite plugin manager.

### Packer

```lua
use {
    "gmek/c-unity.nvim",
    config = function()
        require("c-unity").setup()
    end
}
```

## Configuration

The `setup` function can be called with a configuration table. The following options are available:

```lua
require("c-unity").setup({
    debug = false, -- Enable debug notifications
})
```

## Usage

The plugin works by connecting to a Unity Editor with the accompanying `CUnity.cs` script running. Once connected, you can use the following commands to interact with Unity.

### Commands

| Command        | Description                     |
| -------------- | ------------------------------- |
| `:CUConnect`   | Connect to the Unity Editor.    |
| `:CUDisconnect`| Disconnect from the Unity Editor.|
| `:CUBuild`     | Send a recompile command.       |
| `:CULog`       | Toggle the log window.          |
| `:CULogs`      | Toggle the log window.          |
| `:CUClear`     | Clear the log window.           |

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
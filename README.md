# Modern C++ Starter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A professional, reproducible C++ project template for Linux, powered by Micromamba, CMake, and vcpkg. This starter provides a complete, modern development environment that you can set up and run in minutes, eliminating "it works on my machine" issues for good.

---

## Features

- ✅ **Fully Reproducible Toolchain**: The exact versions of **GCC**, **CMake**, **Ninja**, and other essential tools are managed by **Micromamba**, ensuring perfect consistency across all developer machines and CI/CD runners.
- ✅ **Modern Dependency Management**: Easily add and manage libraries using **vcpkg** with a simple `vcpkg.json` manifest file.
- ✅ **High-Quality Code by Default**: The build is pre-configured with strict compiler warnings (`-Wall -Wextra -Wpedantic`) and enables **AddressSanitizer** and **UndefinedBehaviorSanitizer** in Debug builds to catch bugs early.
- ✅ **Excellent Developer Experience (DX)**: A simple `Makefile` provides an intuitive interface for common tasks, while `compile_commands.json` is automatically generated and linked to the project root for seamless IDE and editor integration (VS Code, CLion, etc.).
- ✅ **Optimized for Speed**: **ccache** is automatically enabled for non-debug builds to provide near-instantaneous subsequent compilations. **Link-Time Optimization (LTO)** is enabled for release builds to maximize performance.
- ✅ **Testing Included**: The project is ready to go with **GoogleTest** for unit and integration testing.
- ✅ **Built-in CI**: The project includes a basic CI workflow for building and test `Debug`, `RelWithDebInfo` and `Release` variants.

---

## Quick Start

**Prerequisites**: `git` and `curl`.

1.  **Clone the project**

    ```bash
    # TODO: Replace with your repository's URL
    git clone https://github.com/akalsi87/cpp-starter.git your-repo-name
    cd your-repo-name
    ```

2.  **Launch the Development Environment**
    This one-time command will download Micromamba, create the sandboxed toolchain environment, and drop you into a new shell with all tools available on your `PATH`.

    ```bash
    ./repo.sh
    ```

    > **Note:** Your shell prompt is now inside the managed environment. All subsequent commands should be run inside this shell. `Ctrl+D` or type `exit` to leave the sub-shell.

3.  **Build and Run Tests**
    Once inside the environment shell, you can use the simple `make` commands:
    ```bash
    make build
    make test
    make help
    ```

---

## Workflow & Commands

This template uses a `Makefile` as a friendly front-end for the underlying CMake build system.

| Command       | Description                                                                               |
| ------------- | ----------------------------------------------------------------------------------------- |
| `make build`  | Compiles the project in the configured build type (default: `Debug`).                     |
| `make test`   | Runs all tests using CTest.                                                               |
| `make format` | Automatically formats all `.cpp` and `.hpp` files in the repository using `clang-format`. |
| `make clean`  | Deletes the build directory for a completely fresh start.                                 |
| `make help`   | Displays a list of all available targets.                                                 |
| `exit`        | To leave the Micromamba development shell, simply type `exit` or press `Ctrl+D`.          |

To build in **Release** mode, you can set the `BUILD_TYPE` variable:

```bash
BUILD_TYPE=Release make build
```

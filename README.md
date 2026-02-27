# Clox

A C implementation of the Lox programming language, as described in the book [Crafting Interpreters](https://craftinginterpreters.com/) by Robert Nystrom.

## Prerequisites

To build and run this project, you will need:

- A C compiler (e.g., `gcc` or `clang`)
- [CMake](https://cmake.org/) (version 3.10 or higher)
- `make` (or another build system supported by CMake)

## Building the Project

Follow these steps to build the project from the command line:

1.  **Create a build directory:**
    ```bash
    mkdir build
    cd build
    ```

2.  **Generate the build files with CMake:**
    ```bash
    cmake ..
    ```

3.  **Compile the project:**
    ```bash
    make
    ```

After a successful build, the `Clox` executable will be located in the `build` directory.

## Usage

You can run `Clox` in two modes: REPL (interactive) or by executing a script file.

### REPL Mode

To start the interactive REPL, run the executable without any arguments:

```bash
./Clox
```

Type Lox code and press Enter to execute it. Press `Ctrl+D` (or `Ctrl+C`) to exit.

### Running a Script

To execute a Lox script file, provide the path to the file as an argument:

```bash
./Clox path/to/script.lox
```

## Running Tests

The project includes several test files in the `tests/` directory organized by feature (e.g., `classes`, `functions`). Many tests include a script file and a corresponding `.expected` file containing the expected output.

To run a test and manually verify its output:

```bash
./Clox tests/classes/classInheritanceTest
```

Compare the printed output with the content of `tests/classes/classInheritanceTest.expected`.

Alternatively, use `ctest` from the `build` directory to run the basic tests configured in CMake:

```bash
ctest
```

## Project Structure

- `src/`: Contains the C source and header files for the interpreter.
- `tests/`: Contains test scripts and expected output files.
- `CMakeLists.txt`: Configuration for the CMake build system.

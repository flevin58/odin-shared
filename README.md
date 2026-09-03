# Odin Bindings

The core functionality of this repository is based on the awesome [odin-c-bindgen](https://github.com/karl-zylinski/odin-c-bindgen.git) program by Karl Zylinski
Using this library has its challenges, so I decided to automate the process by using a Makefile for each external library that will clone the library repo and automate the installation process.

Note: Since I am using also Rust bindgen, I decided to use a dedicated env variable $OBINDGEN to differentiate them apart.
You will need to set the $OBINDGEN env to the path where you installed the software.
Example:
```code
export OBINDGEN=~/.local/bin/bindgen
```

## Repository structure
In this repository I am collecting a series of "c" libraries to be used with Odin.
I will try to keep the same folder structure for all libraries:

```code
.
├── README.md
└── <library>
    ├── bindgen.sjson
    ├── example.odin
    └── Makefile
```
Each library will contain at least the following files:
- Makefile (Fully automatic installation in $ODIN_ROOT/shared/<library>)
- bindgen.sjson (Configuration file used by the bindgen application)
- example.odin (A small example showing a simple usage of the library)

Note that there could be other files depending on the complexity of the library.

## Prerequisites
You need to have installed the following programs:
- clang (the c/c++ compiler)
- ar (the archiver used to generate the library)
- git (used to clone the original external librarey repository)
- bindgen (generates the actual odin bindings to allow import "shared:<library>")
  

# sys-dependencies
_Manage system dependencies the npm way_

sys-dependencies is a simple utility written in pure bash to install and 
update system dependencies defined in a `package.json` file, in a similar way 
to [`npm`](https://www.npmjs.com).  
It is designed to integrate smoothly with 
[npm scripts](https://docs.npmjs.com/cli/v7/using-npm/scripts), or to be used 
independently as a shell command.  
Rather than hosting and distributing packages, the purpose of sys-dependencies 
is to provide a standard way to declare dependencies managed by various 
package managers.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [Installation](#installation)
  - [Npm package](#npm-package)
  - [Install script](#install-script)
  - [Source code](#source-code)
  - [Verifying and debugging](#verifying-and-debugging)
- [Updating](#updating)
  - [Npm package](#npm-package-1)
  - [Shell script](#shell-script)
- [Usage](#usage)
  - [Declaring system dependencies](#declaring-system-dependencies)
  - [Installing packages](#installing-packages)
  - [Updating packages](#updating-packages)
- [Internal modules](#internal-modules)
  - [Package managers](#package-managers)
  - [Node](#node)
  - [Python](#python)
  - [Git repositories](#git-repositories)
  - [Config files](#config-files)
  - [Parameters](#parameters)
  - [Core modules](#core-modules)
- [Build your own modules](#build-your-own-modules)
  - [Module name and location](#module-name-and-location)
  - [Module structure](#module-structure)
    - [Package.json](#packagejson)
    - [Package.bash](#packagebash)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation
sys-dependencies can be installed in three different ways: as a 
[npm package](#npm-package), using a [helper script](#install-script) or by 
[cloning this repo](#source-code). The way you decide to install it depends on 
your intended usage:
- If you plan to integrate sys-dependencies as part of your npm scripts, or 
nest it as a npm command within your package, you should [install it as a npm 
package](#npm-package)
- If you need to use sys-dependencies separately from npm (e.g. if your goal is 
to install npm itself), and be able to access it across your system and not 
just within a particular package, you should install it as a shell command 
either using the [install script](#install-script) or by manually [cloning the 
repo](#source-code)

### Npm package
To install sys-dependencies as a npm dependency, simply run the following:
```bash
npm install --save-dev sys-dependencies
```
sys-dependencies will be available to use in your npm scripts using the `spm` 
command (see [Usage](#usage)).

### Install script
To use the [install script](./install.bash), you can either <a
href="https://raw.githubusercontent.com/romainv/sys-dependencies/master/install.bash"
download>download it</a> and run it manually, or use the following command:
```bash
curl -Lo- https://raw.githubusercontent.com/romainv/sys-dependencies/master/install.bash | bash
```
This requires that [`curl`](http://curl.haxx.se) be installed as well as
[`git`](https://git-scm.com), as the install script will clone sys-dependencies'
repository to `~/.spm`. It will also install sys-dependencies' [own 
dependencies](./sys_modules/core/package.json) and add a few lines in your
`~/.bashrc` file to make the `spm` command available in your shell.  
To customize the installation directory, you can set the `SPM_DIR` env variable
to your chosen location: `export SPM_DIR=~/custom-location && curl -Lo- 
<install_script_url> | bash`.

### Source code
This way to install sys-dependencies is essentially equivalent to executing the
[install script](./install.bash), so you can refer to it for more details. The
steps are as follows:
```bash
git clone https://github.com/romainv/sys-dependencies.git ~/.spm
~/.spm/spm update spm
source ~/.bashrc
```
This obviously requires that [`git`](https://git-scm.com) be installed. Other
dependencies will be installed automatically by sys-dependencies itself.

### Verifying and debugging
To verify that the installation succeeded, run:
```bash
command -v spm
```
This should output `spm` if the installation was successful. Please note that
`which spm` will not work, since `spm` is a sourced shell function, not an
executable binary. 
If you get `spm: command not found`, try to restart your shell or run the
following:
```bash
source ~/.bash
```
This should make the `spm` command available in the current shell.

## Updating

### Npm package
To update sys-dependencies if it was installed as a npm package, use npm's
[default commands](https://docs.npmjs.com/cli/v7/commands/npm-update) to manage 
dependencies versions:
```bash
npm update sys-dependencies
```
To upgrade to the latest version in case there was a major version change:
```bash
npm install sys-dependencies@latest
```

### Shell script
To update the shell command, simply use the following:
```bash
spm update spm
```

## Usage
sys-dependencies provides the `spm` command to manage dependencies. For basic
usage instructions, run `spm help` to display the available commands and 
arguments.  
Below we detail how to [define](#declaring-system-dependencies) your system 
dependencies, [install](#installing-packages) and 
[update](#upgrading-packages) them.

### Declaring system dependencies
The typical way to use sys-dependencies is by declaring the modules that your
package depends on in it's `package.json` file (if you don't have one, simply
create a new file at the root of your repository). Similar to how you'd declare 
your node dependencies, you can declare your system dependencies as follows:
```json
{
  "sysDependencies": {
    "<module-id>": "<module-version>"
  }
}
```
In the above:
- `<module-id>` can be in two formats: `<module-name>` or 
`<module-type>/<module-name>` (see the [modules section](#internal-modules) 
below)
- `<module-version>` defines the version to install, similar to how npm 
defines them. To not set a specific version but use the latest available, you
can use `*` 

**OS-specific dependencies**  
If you want to declare dependencies which are
specific to a particular OS, you can nest them under the identifier of this OS
as follows:
```json
{
  "sysDependencies": {
    "<OS-ID>": {
      "<module-id>": "<module-version>"
    }
  }
}
```
To get the list of OS identifiers, check the [`getOS`](./src/utils/getOs.bash) 
function.

### Installing packages
The basic usage to install dependencies defined in `package.json` is:
```bash
spm install
```
This will look for your current repository's `package.json` and install the
dependencies defined under `sysDependencies` (see
[previous section](#declaring-system-dependencies)).

If you installed sys-dependencies as a npm package, you will typically want to
execute it after installing the npm dependencies. In the `scripts` section of 
your `package.json`, add the following:
```json
{
  "scripts": {
    "postinstall": "spm install"
  }
}
```

To install a specific package (not necessarily declared in `package.json`),
simply specify its name:
```bash
spm install <package>
```

### Updating packages
You can update your dependencies using:
```bash
spm update
```
or to update a specific package:
```bash
spm update <package>
```

## Internal modules
sys-dependencies bundles a few modules which aim at specifying dependencies 
using your system's package managers. It also provides a few utilities to 
manage the installation of config files and the input of parameters. 

### Package managers
You can specify dependencies for the following package managers, provided they
are compatible with your operating system:
- `apt/<package>` to use [apt](https://ubuntu.com/server/docs/package-management)
- `brew/<package>` to use [brew](https://brew.sh)
- `gem/<package>` to use [gem](https://rubygems.org)
- `pip/<package>` to use [pip](https://pypi.org/project/pip)
- `snap/<package>` to use [snap](https://snapcraft.io)  
- to declare local [npm](https://www.npmjs.com) dependencies, declare them as 
usual under the `dependencies` section of your `package.json`.  
- to declare global [npm](https://www.npmjs.com) dependencies, you can use 
`npm/<package>` under the `sysDependencies` section of your `package.json`.

### Node
You can install `node` and `npm` on your system by using the `node` module: 
`spm install node`. This will install [`nvm`](https://github.com/nvm-sh/nvm)
which is used to manage node's installation and updates. 
To specify which version to install, you can either place a `.nvmrc` file at
the root of your repo (see
[instructions](https://github.com/nvm-sh/nvm#nvmrc)), or use one of the
following strategies in the `sysDependencies` section of your `package.json`:
- `"node/<branch>": "*"` to install the latest version of the specified
	`<branch>` (e.g. [erbium](https://nodejs.org/en/about/releases/)) 
- `"node": "10.10.0"` to install a specific version  
See also [nvm usage](https://github.com/nvm-sh/nvm#usage) and sys-dependencies' 
[node module](./sys_modules/node) for more details.

### Python
To install python, simply use `spm install python`. This will install
[`pyenv`](https://github.com/pyenv/pyenv) which is used to manage python's
installation and updates.  
To specify which version to install, place a `.python-version` file at the root
of your repo. See [pyenv
usage](https://github.com/pyenv/pyenv#choosing-the-python-version) and the
[python module](./sys_modules/python) for more details.

### Git repositories
You can specify remote git repositories to clone and keep updated at a 
particular location on your system by using the [repo
module](./sys_modules/repo): `"repo/<local-dir>": "<remote-url>"`.

### Config files
To manipulate files, you can use the internal [`file`](./sys_modules/file) 
module which works as follows:
```json
{
  "sysDependencies": {
    "file/<target-file>": {
      "<action>": "<arguments>",
      "onUpdate": "<onUpdate-command>"
    }
  }
}
```
In the above sample:  
- `<target-file>` is the path to the target file. It can contain a tilde `~` to
	refer to the `$HOME` folder. To point at your OS' rcfile, you can use
	`<rcfile>` (see [`decodeFilename`](./sys_modules/file/decodeFilename.bash)
	for details)  
- `"<action>": "<arguments>"` can be one of the following (see
	[`processConfigFile`](./sys_modules/file/processConfigFile.bash) for
	details):  
	- `"copy": "<source-file>"`: to copy the `<source-file>` to the 
	`<target-file>`. The `<source-file>` path can be relative to the current
	module's `package.json`   
  - `"addToFile": ["<line1>", <line2>", ...]`: to append lines `<line1>`, 
  `<line2>` etc. at the end of `<target-file>` (lines already existing in the
  `<target-file>` won't be duplicated)  
  - `"generate": "<command>"`: to generate the `<target-file>` by executing the 
  supplied `command`
  - `"link": "<source-file>"`: to create a symlink of the `<source-file>` to 
  the `<target-file>`  
  - `"ini": { "<section>": { "<key>": "<value>" } }`: generates the 
  `<target-file>` as an INI file, where the `<key>`/`<value>` pairs nested in
  each `<section>` are provided in JSON format  
- `onUpdate` is optional, and will be triggered if the target file was created 
or modified  

### Parameters
If you need dynamic env variables throughout the setup process, you can use the
[`param`](./src/processParameter.bash) module as follows:  
```json
{
  "sysDependencies": {
    "param/<PARAM_NAME>": "<value>"
  }
}
```
where:  
- `<PARAM_NAME>` is the name of the parameter.    
- `<value>` is a bash command that will output the value to use for this
	parameter. If you leave it empty, user will be prompted to enter the value
	manually  
- If some parameters are sensitive and you don't want their values to be 
displayed, you can append an asterisk `*` at the end of the parameter name: 
`<PARAM_NAME*>` (e.g. `"param/FOO*": "cat ~/.secret"`)  

Parameters can be used in `<arguments>` of the [file module](#config-files). To
use them, refer to them with a `$` prefix like you would in bash:
`$PARAM_NAME`. This also applies inside of `<source-file>`, where the
references will be replaced by the parameter's `<value>`.  
To use the parameters in your module's functions declared in
[`package.bash`](#packagebash), you can access them via the `SPM_PARAMS`
associative array as follows: `${SPM_PARAMS[PARAM_NAME]}`.

### Core modules
sys-dependencies uses internal modules to manage its own dependencies. The
system dependencies required to run `spm` are declared in the [core
module](./sys_modules/core).  
The [spm module](./sys_modules/spm) handles the installation of
sys-dependencies on the host system and its own updates.

## Build your own modules
To extend sys-dependencies' features, you can build your own modules locally 
and bundle them with your code.

### Module name and location
Place your modules under a `sys_modules` folder at the root of your repo (next
to where node typically creates its `node_modules` folder).  
The folder name you choose will be your module's id (`<module-id>` in the below 
file tree).  
A typical folder structure for a node project would look like this:
```
.
+-- node_modules
+-- sys_modules
|   +-- <module-id>
+-- package.json
```
When looking for modules, sys-dependencies will search upwards from the current
working directory for the `sys_modules/<module-id>` folder. If it doesn't find
one, it will look for internal modules. This way, you can easily override an
internal module by simply placing one with the same name in a local
`sys_modules` folder.

### Module structure
A module consists of a required [`package.json`](#packagejson) file that will 
describe the module's name and its dependencies, and an optional 
[`package.bash`](#packagebash) that declares the bash functions used to
manage the module.
```
.
+-- <module-id>
|   +-- package.json
|   +-- package.bash
```

#### Package.json
The `package.json` file contains two optional fields: `name` and 
`sysDependencies`. The former provides a more descriptive name than the module
id, the latter describes the module's dependencies as explained in 
[Declaring system dependencies](#declaring-system-dependencies).
```json
{
  "name": "<module-name>",
  "sysDependencies": {
    "<module-id>": "<module-version>"
  }
}
```

#### Package.bash
The `package.bash` file is optional. If provided, it should declare the
functions that will be used to manage the module's installation and updates.  
For an overview of how each function is used, check the 
[processModule](./src/processModule.bash) function. For a live example, check 
spm's internal [package.bash](./sys_modules/spm/package.bash).  

Each function will be passed two arguments: the first is the module's `name`, 
the second its dependency `version`, as in `"<module-type>/<name>": 
"<version>"`.  
Below is the list of functions that should be declared:  
- **_checkInstall (required)_**: it should return a boolean (`true` if module 
is installed), and not output anything to `stdout` or `stderr` as it would be 
interpreted as an error.  
- **_runInstall (required)_**: it should install the module and cause 
`checkInstall` to be truthy. The installation log can be output to `stdout` or 
`stderr`, and will be displayed if an error occurred.  
- **_checkUpdates (required)_**: it should return a boolean (`true` if an 
update is available), and not output anything to `stdout` or `stderr` as it 
would be interpreted as an error.  
- **_runUpdates (required)_**: it should update the module and cause 
`checkUpdate` to be falsy. The update log can be output to `stdout` or 
`stderr`, and will be displayed if an error occurred.  
- **_getInstalledVersion (required)_**: it should return the currently 
installed version of the module.
- **_getLatestVersion (required)_**: it should return the latest version 
available for the module.
- **_preProcess (optional)_**: it will be executed before any other function 
once the module is imported. You can use it to dynamically adjust the 
environment before processing the module, such as adding dependencies. If the 
function produced an output to `stdout` or `stderr`, it should return `true`, 
`false` otherwise so that sys-dependencies can properly display progress.  
- **_postProcess (optional)_**: it will be executed after all the other 
functions. You can use it to display information or further configuration after 
a module was installed or updated for instance. If the function produced an 
output to `stdout` or `stderr`, it should return `true`, `false` otherwise so 
that sys-dependencies can properly display progress.  

## License
sys-dependencies is [MIT licensed](./LICENSE)

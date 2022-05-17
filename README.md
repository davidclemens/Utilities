# Utilities for MATLAB

Multiple useful utilities for MATLAB.

## Maintain as a git submodule
### Install submodule
1. To add the Utilities repository as a git submodule run:
```
git submodule add https://github.com/davidclemens/Utilities.git <relativePathWithinSuperrepository>
```
This should create a `.gitmodules` file in the root of the superrepository, if it doesn't exist yet.
2. In that file add the `branch = release` line. So that it looks like this:
```
[submodule "<relativePathWithinSuperrepository>"]
	path = <relativePathWithinSuperrepository>
	url = https://github.com/davidclemens/Utilities.git
	branch = release
```

### Update submodule
1. If you want to pull the latest release from this repository to your submodule run
```
git submodule update --remote --merge
```

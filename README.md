# Utilities for MATLAB

Multiple useful utilities for MATLAB.

## Maintain as a git submodule

### Install submodule

1. To add the Utilities repository as a git submodule run:

    ```shell
    git submodule add https://github.com/davidclemens/Utilities.git <relativePathWithinSuperrepository>
    ```

    This should create a `.gitmodules` file in the root of the superrepository, if it doesn't exist yet.
2. In that file add the `branch = release` line. So that it looks like this:

    ```config
    [submodule "<relativePathWithinSuperrepository>"]
    path = <relativePathWithinSuperrepository>
    url = https://github.com/davidclemens/Utilities.git
    branch = release
    ```

### Update submodule

1. If you want to pull the latest release from this repository to your submodule run

    ```shell
    git submodule update --remote --merge
    ```

## Utilities documentation

### List of functions/classes

#### arrayhom()

Homogenizes arrays with varying shapes.

#### dec2basen()

Converts decimal integers to their base b representation using custom symbols.

#### findContinuousSections()

Finds start & end indices as well as lengths of continuous sequences of values larger than a given threshold.

#### toolbox.isOnReleaseBranch()

:construction: work in progress ...

#### readApolloFile()

Reads a `.csv` file generated by the software of an Apollo Scientific AS-C6L DIC analyzer.

#### readCalkulateResultFile()

Reads a `.csv` file generated by the AlkalinityAnalysis software.

#### sub2excelRange()

Converts two 2D subscript pairs startSub and endSub to an Excel range.

#### table.formatSpec [class]

This enumeration class defines the formatSpec for all relevant classes (as defined in [textscan](https://www.mathworks.com/help/releases/R2017b/matlab/ref/textscan.html#inputarg_formatSpec")) as well as their constructors.

#### table.readTableFile()

Reads an Excel file with four header rows that define the column names, descriptions, units and data types, which are returned as properties of the resulting table.

#### table.writeTableFile()

Writes a table to an Excel table with four header rows that define the column names, descriptions, units and data types of each column. That file can be read again by table.readTableFile() and all data is restored.

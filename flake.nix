{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      myvscode = pkgs.vscode-with-extensions.override {
        vscodeExtensions = (with pkgs.vscode-extensions; [
        equinusocio.vsc-material-theme
        equinusocio.vsc-material-theme-icons
        vscodevim.vim
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-renderers
        ]);
      };
    in {
      devShell = pkgs.mkShell {
        name = "python-venv";
        venvDir = "./.venv";
        buildInputs = with pkgs; [
          myvscode
          (python3.withPackages(ps: with ps; [
            ipython
            pip
            jupyter
            widgetsnbextension
            ipympl
            jupyter-nbextensions-configurator
            jedi-language-server
            osmnx
            ipywidgets
            mypy
            notebook
            pandas
                                    numpy
            plotly
            geopandas
            geodatasets
            pyogrio
            geopy
            matplotlib
            pyproj
            folium
            seaborn
            mapclassify
            scipy
            shapely
            xarray
            rioxarray
            rasterio
          ]))
        ];
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
          pip install -r requirements.txt
        '';

        shellHook = ''
            export BROWSER=brave
                # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
    # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
            export PIP_PREFIX=$(pwd)/_build/pip_packages
            export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"
            unset SOURCE_DATE_EPOCH
            #jupyter lab
        '';

        postShellHook = ''
          # allow pip to install wheels
          unset SOURCE_DATE_EPOCH
        '';
      };
    }
  );
}

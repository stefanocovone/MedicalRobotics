#!/bin/bash

# Define array of repositories with URLs and names
repositories=(
    "https://github.com/SofaDefrost/STLIB.git STLIB"
    "https://github.com/SofaDefrost/SoftRobots.git SoftRobots"
    "https://github.com/SofaDefrost/ModelOrderReduction.git ModelOrderReduction"
    "https://github.com/sofa-framework/SofaPython3.git SofaPython3"
)

# Define array of packages to install with apt
packages=(
    "build-essential"
    "software-properties-common"
    "gcc-9"
    "clang-12"
    "ninja-build"
    "ccache"
    "libtinyxml2-dev"
    "libopengl0"
    "libpng-dev"
    "libjpeg-dev"
    "libtiff-dev"
    "libglew-dev"
    "zlib1g-dev"
    "libeigen3-dev"
    "libstdc++-10-dev"
    "libqt5webengine5"
    "libqt5charts5"
    "libqt5widgets5")

# Define array of packages to install with pip
pip_packages=(
    "pybind11"
    "PyQt5"
)

# Function to clone repositories
clone_repositories() {
    echo "Cloning repositories..."
    for repo in "${repositories[@]}"; do
        url=$(echo "$repo" | cut -d' ' -f1)
        name=$(echo "$repo" | cut -d' ' -f2)
        git clone --branch v23.06 "$url" "$HOME/ext_sofa_plugins/$name"
        # Create CMakeLists.txt file in the plugin folder
        cat > "$HOME/ext_sofa_plugins/$name/CMakeLists.txt" <<EOF
cmake_minimum_required(VERSION 2.8.12)

find_package(SofaFramework)

sofa_add_subdirectory(plugin ModelOrderReduction/ ModelOrderReduction VERSION 1.0)
sofa_add_subdirectory(plugin STLIB/ STLIB VERSION 3.0)
sofa_add_subdirectory(plugin SoftRobots/ SoftRobots VERSION 1.0)
sofa_add_subdirectory(plugin SofaPython3/ SofaPython3 VERSION 20.12.00)
EOF
    done

    # Clone the sofa repository
    git clone -b v23.06 https://github.com/sofa-framework/sofa.git "$HOME/sofa/src"
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
}

# Function to install packages with apt
install_apt_packages() {
    echo "Installing apt packages..."
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package"; then
            sudo apt-get install -y "$package"
        else
            echo "$package is already installed."
        fi
    done
}

# Function to install packages with pip
install_pip_packages() {
    echo "Installing pip packages..."
    for package in "${pip_packages[@]}"; do
        if ! python3 -m pip show "$package" &> /dev/null; then
            python3 -m pip install "$package"
        else
            echo "$package is already installed."
        fi
    done
}

# Function to install packages with snap
install_snap_packages() {
    echo "Installing snap packages..."
    if ! snap list | grep -q cmake; then
        sudo snap install cmake --classic
    else
        echo "cmake is already installed."
    fi
}

# Function to add PYTHONPATH to ~/.bashrc
add_pythonpath_to_bashrc() {
    echo "Adding PYTHONPATH to ~/.bashrc..."
    if ! grep -q "export PYTHONPATH=~/sofa/src/tools/sofa-launcher" ~/.bashrc; then
        echo "export PYTHONPATH=~/sofa/src/tools/sofa-launcher" >> ~/.bashrc
    else
        echo "PYTHONPATH is already added to ~/.bashrc."
    fi
}

# Function to create ~/sofa/build directory
create_sofa_build_directory() {
    echo "Creating ~/sofa/build directory..."
    mkdir -p ~/sofa/build
}

# Function to run cmake-gui
run_cmake_gui() {
    echo "Running cmake-gui..."
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DSOFA_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=clang-12 \
        -DCMAKE_CXX_COMPILER=clang++-12 \
        -DAPPLICATION_GETDEPRECATEDCOMPONENTS=ON \
        -DCIMGPLUGIN_BUILD_TESTS=ON \
        -DPLUGIN_CGALPLUGIN=ON \
        -DPLUGIN_CIMGPLUGIN=ON \
        -DPLUGIN_COLLISIONOBBCAPSULE=ON \
        -DPLUGIN_MESHSTEPLOADER=ON \
        -DPLUGIN_MODELORDERREDUCTION=ON \
        -DPLUGIN_SOFAPYTHON3=ON \
        -DPLUGIN_SOFTROBOTS=ON \
        -DPLUGIN_STLIB=ON \
        -DSOFA_BUILD_WITH_PCH_ENABLED=ON \
        -DSOFA_ENABLE_LEGACY_HEADERS=ON \
        -DSOFA_EXTERNAL_DIRECTORIES="$HOME/ext_sofa_plugins" \
        -DSOFA_GUI_QT_ENABLE_QDOCBROWSER=ON \
        -DSOFA_USE_CCACHE=ON \
        -Dpybind11_DIR="$HOME/.local/lib/python3.8/site-packages/pybind11/share/cmake/pybind11"
        ~/sofa/src
    cmake-gui ~/sofa/src
}

# Main function
main() {
    clone_repositories
    install_apt_packages
    install_pip_packages
    install_snap_packages
    add_pythonpath_to_bashrc
    create_sofa_build_directory
    run_cmake_gui
}

# Execute the main function
main

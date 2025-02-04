#!/bin/env bash

# Now the tools
export TOOLS_ROOT="/home/$(whoami)/asic_tools"
export MAGIC_ROOT="$TOOLS_ROOT/magic"
export IVERILOG_ROOT="$TOOLS_ROOT/iverilog"
export FPGA_VER="https://github.com/YosysHQ/fpga-toolchain/releases/download/nightly-20210101/fpga-toolchain-linux_x86_64-nightly-20210101.tar.xz"
export FPGA_ROOT="$TOOLS_ROOT/yosys_nightly"
export RISCV_GCC="$TOOLS_ROOT/riscv-gcc"

# some extra packages
echo 12345 | sudo -S apt-get -y install xdot vim

# Create directory
mkdir $TOOLS_ROOT

# Prepare and clone magic
echo "[-- Message --] Cloning magic"
git clone git://opencircuitdesign.com/magic $MAGIC_ROOT
cd $MAGIC_ROOT
git checkout 8.3.160
./configure --prefix=$TOOLS_ROOT/binaries/magic
make -j$(nproc)

# Install iverilog
echo "[-- Message --] Downloading iverilog release"
wget -P $IVERILOG_ROOT https://github.com/steveicarus/iverilog/archive/refs/tags/v11_0.tar.gz
cd $IVERILOG_ROOT
echo "[-- Message --] Installing iverilog"
tar -xf v11_0.tar.gz
cd iverilog-11_0/
autoconf
./configure --prefix=$TOOLS_ROOT/binaries/iverilog
make -j$(nproc)

# Installing cocotb
echo "[-- Message --] Installing cocotb"
pip3 install cocotb --user

# summary
cd $TOOLS_ROOT
git clone https://github.com/mattvenn/openlane_summary

# precheck
cd $TOOLS_ROOT
git clone https://github.com/efabless/open_mpw_precheck
cd open_mpw_precheck
git checkout cbd5fd47c4aaa2252e69b8c568592f744e052b23
docker pull efabless/open_mpw_precheck:latest


# FPGA tools
wget -P $FPGA_ROOT $FPGA_VER
cd $FPGA_ROOT
tar -xf fpga-toolchain-linux_x86_64-nightly-20210101.tar.xz

# Lastly, SiFive
wget -P $RISCV_GCC https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2020.04.1-x86_64-linux-ubuntu14.tar.gz
cd $RISCV_GCC
tar -xf riscv64-unknown-elf-gcc-8.3.0-2020.04.1-x86_64-linux-ubuntu14.tar.gz

## adding stuff to bashrc
echo 'export TOOLS_ROOT="/home/$(whoami)/asic_tools"' >> ~/.bashrc
echo 'export RISCV_GCC="$TOOLS_ROOT/riscv-gcc"' >> ~/.bashrc
echo 'export FPGA_ROOT="$TOOLS_ROOT/yosys_nightly"' >> ~/.bashrc
echo 'export PATH=$PATH:$FPGA_ROOT/fpga-toolchain/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$RISCV_GCC/riscv64-unknown-elf-gcc-8.3.0-2020.04.1-x86_64-linux-ubuntu14/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$TOOLS_ROOT/openlane_summary' >> ~/.bashrc
echo 'export PDK_ROOT="$TOOLS_ROOT/pdk"' >> ~/.bashrc
echo 'export PDK_PATH="$PDK_ROOT/sky130A"' >> ~/.bashrc
echo 'export OPENLANE_ROOT="$TOOLS_ROOT/openlane"' >> ~/.bashrc
echo 'export CARAVEL_ROOT="$TOOLS_ROOT/caravel_user_project/caravel"' >> ~/.bashrc
echo 'export TARGET_PATH="$TOOLS_ROOT/caravel_user_project"' >> ~/.bashrc

echo 'export GCC_PREFIX=riscv64-unknown-elf' >> ~/.bashrc
echo 'export GCC_PATH=$RISCV_GCC/riscv64-unknown-elf-gcc-8.3.0-2020.04.1-x86_64-linux-ubuntu14/bin' >> ~/.bashrc
echo 'export OPENLANE_TAG=v0.15' >> ~/.bashrc
echo 'export IMAGE_NAME=efabless/openlane:$OPENLANE_TAG' >> ~/.bashrc



cd $MAGIC_ROOT
echo "[-- Message --] Installing magic"
make -j$(nproc) install
echo 'export PATH=$PATH:$TOOLS_ROOT/binaries/magic/bin' >> ~/.bashrc

cd $IVERILOG_ROOT/iverilog-11_0
make -j$(nproc) install
echo 'export PATH=$PATH:$TOOLS_ROOT/binaries/iverilog/bin' >> ~/.bashrc

# OpenLANE stuff
echo 12345 | sudo -S -u root usermod -aG docker zerotoasic

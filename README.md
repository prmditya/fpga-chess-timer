# FPGA Chess Timer

This repository contains the implementation of an FPGA-based Chess Timer. The project aims to design and develop a chess timer using an FPGA, providing precise time management and control during chess games.

https://github.com/user-attachments/assets/6561c64d-ba8e-49ad-8ce5-9c1101229af4

## Features

- **Time Tracking**: Tracks and displays time for both players.
- **Start/Stop Functionality**: Enables players to start and stop their timers accurately.
- **Reset Timer**: Resets the timer to the initial configuration.
- **User Interface**: Uses LED displays or LCD for visual feedback.

## Getting Started

### Prerequisites

- FPGA Development Board (e.g., Altera DE10-Lite, Xilinx Artix-7, etc.)
- FPGA Toolchain (e.g., Quartus, Vivado, etc.)
- Basic understanding of Verilog/VHDL
- USB Blaster or equivalent for programming

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/prmditya/fpga-chess-timer.git
   ```
2. Open the project files in your preferred FPGA IDE.

### Synthesis and Programming

1. Synthesize the design using your FPGA IDE.
2. Generate the bitstream file.
3. Upload the bitstream to your FPGA board using the appropriate programmer tool.

## Usage

1. Power on the FPGA board.
2. Use the physical buttons or switches on the board to:
   - Start/stop the timer
   - Switch turns between players
   - Reset the timer
3. Observe the timer display (LED/LCD).

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, feel free to open an issue or create a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

- Thanks to all of my team that are contributing to this project. Ahmad Azhar Kaffi, Bizzati Hanif R.F, M. Yusuf Ramadhan, Pradytia Trido, Regas Ryandhi Adhitama and also our Lecture Dahnial Syauqy, S.T., M.T.
- Inspired by traditional chess timers and the potential of FPGA technology.

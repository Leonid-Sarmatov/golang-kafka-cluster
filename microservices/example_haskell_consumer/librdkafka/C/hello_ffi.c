#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void hello_ffi() {
    printf("Hello, FFI\n"); 
}

char* modifed_string(char* input) {

    size_t size = strlen(input) + strlen("I was received: ") + 1;

    char* result = (char*)malloc(size);
    if (result == NULL) {
        printf("Error, can not allocate memory!\n");
        return NULL;
    }

    snprintf(result, size, "I was received: %s", input);

    printf("I was received: %s", input);

    return result;
}
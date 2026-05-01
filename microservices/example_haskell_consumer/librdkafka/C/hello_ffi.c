#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>


void hello_ffi() {
    printf("Hello, FFI\n"); 
}

char* modifed_string(char* input) {
    size_t size = strlen(input) + strlen("[C]: I was received: ") + 1;
    char* result = (char*)malloc(size);
    if (result == NULL) {
        printf("[C ERROR]: can not allocate memory!\n");
        return NULL;
    }
    snprintf(result, size, "[C]: I was received: %s", input);
    printf("[C]: I was received: %s\n", input);
    return result;
}

typedef struct {
    int event_id;
} context_t;

typedef void (*callback_t)(context_t* ctx);

void run_event_loop(callback_t cb) {
    setbuf(stdout, NULL);
    int i = 0;
    while (1) {
        printf("[C]: (pointer callback) generating event %d\n", i);
        context_t* ctx = (context_t*)malloc(sizeof(context_t));
        ctx->event_id = i;
        cb(ctx);
        free(ctx);
        sleep(1);
        i++;
    }
}
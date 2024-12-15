#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <openssl/sha.h>

#include <time.h>

#define SHA256_DIGEST_LENGTH 32

void sha256_hash_string (char unsigned hash[SHA256_DIGEST_LENGTH], char outputBuffer[65])
{
    int i = 0;

    for(i = 0; i < SHA256_DIGEST_LENGTH; i++)
    {
        sprintf(outputBuffer + (i * 2), "%02x", hash[i]);
    }

    outputBuffer[64] = 0;
}

int calc_sha256 (char* buffer, char unsigned output_hash[SHA256_DIGEST_LENGTH],int length)
{
    char hash[SHA256_DIGEST_LENGTH];
    // int length = strlen(buffer);

    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, buffer, length);

    SHA256_Final(output_hash, &sha256);

    // SHA256_Final(hash, &sha256);
    // sha256_hash_string(hash, output);

    return 0;
}      



int main (int argc, char** argv)
{
    char calc_hash_string[65];

    char hash[SHA256_DIGEST_LENGTH];

    clock_t start = clock();

    calc_sha256("abc", hash,3);


    for (int i=0;i<100000000;i++)
    {
        calc_sha256(hash, hash,32);
    }

    sha256_hash_string(hash, calc_hash_string);
    printf("%s\r\n",calc_hash_string);

    clock_t end = clock();
    float seconds = (float)(end - start);// / CLOCKS_PER_SEC;

    printf("%f\r\n",seconds);
}



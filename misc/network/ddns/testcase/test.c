#include <stdio.h>
#include <string.h>

unsigned enc_key = 0xab;

char tsig_key[1024];
char tsig_secret[1024];

enc(char *word, size_t size)
{
	int idx;
	for (idx = 0; idx < size; idx++) {
		word[idx] = word[idx] ^ enc_key;
	}
	printf("idx is %d\n",idx);
	word[idx] = '\0';
}

dec(char *word, size_t size)
{
	int idx;
	for (idx = 0; idx < size; idx++) {
		word[idx] = word[idx] ^ enc_key;
	}
}

main()
{
	strcpy(tsig_key, "rndc-key");
	strcpy(tsig_secret, "xsDJgO6KYgo7vVIArjsZ6Q==");

	printf("tsig_key %s secret %s\n", tsig_key, tsig_secret);
	enc(tsig_key, strlen(tsig_key));
	enc(tsig_secret, strlen(tsig_secret));
	printf("tsig_key %s secret %s\n", tsig_key, tsig_secret);
	dec(tsig_key, strlen(tsig_key));
	dec(tsig_secret, strlen(tsig_secret));
	printf("tsig_key %s secret %s\n", tsig_key, tsig_secret);

}

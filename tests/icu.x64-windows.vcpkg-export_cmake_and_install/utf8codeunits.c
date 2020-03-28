#include <stdio.h>
#include <stdlib.h>

#include <unicode/utf8.h>

int main(int argc, char **argv)
{
	UChar32 c;
	/* ICU defines its own bool type to be used
	 * with their macro */
	UBool err = FALSE;
	/* ICU uses C99 types like uint8_t */
	uint8_t bytes[4] = {0};
	/* probably should be size_t not int32_t, but
	 * just matching what their macro expects */
	int32_t written = 0, i;
	char *parsed;

	if (argc != 2)
	{
		fprintf(stderr, "Usage: %s codepoint\n", *argv);
		exit(EXIT_FAILURE);
	}
	c = strtol(argv[1], &parsed, 16);
	if (!*argv[1] || *parsed)
	{
		fprintf(stderr,
			"Cannot parse codepoint: U+%s\n", argv[1]);
		exit(EXIT_FAILURE);
	}

	/* this is a macro, and updates the variables
	 * directly. No need to pass addresses.
	 * We're saying: write to "bytes", tell us how
	 * many were "written", limit it to four */
	U8_APPEND(bytes, written, 4, c, err);
	if (err == TRUE)
	{
		fprintf(stderr, "Invalid codepoint: U+%s\n", argv[1]);
		exit(EXIT_FAILURE);
	}

	/* print in format 'xxd -r' can read */
	printf("0: ");
	for (i = 0; i < written; ++i)
		printf("%2x", bytes[i]);
	puts("");
	return EXIT_SUCCESS;
}

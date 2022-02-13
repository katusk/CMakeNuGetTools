/*** nomarks.c ***/

#include <stdlib.h>

#include <unicode/uchar.h>
#include <unicode/unorm2.h>
#include <unicode/ustdio.h>
#include <unicode/utf16.h>

/* Limit to how many decomposed UTF-16 units a single
 * codepoint will become in NFD. I don't know the
 * correct value here so I chose a value that seems
 * to be overkill */
#define MAX_DECOMP_LEN 16

// For sample_binary.cpp
int f(int /*argc*/, const char * /*argv*/[]);

int main(void)
{
    long i, n;
    UChar32 c;
    UFILE *in, *out;
    UChar decomp[MAX_DECOMP_LEN];
    UErrorCode status = U_ZERO_ERROR;
    UNormalizer2 *norm;

    out = u_get_stdout();

    in = u_finit(stdin, NULL, NULL);
    if (!in)
    {
        /* using stdio functions with stderr and ustdio
         * with stdout. Mixing the two on a single file
         * handle would probably be bad. */
        fputs("Error opening stdin as UFILE\n", stderr);
        return EXIT_FAILURE;
    }

    /* create a normalizer, in this case one going to NFD */
    norm = (UNormalizer2 *)unorm2_getNFDInstance(&status);
    if (U_FAILURE(status)) {
        fprintf(stderr,
            "unorm2_getNFDInstance(): %s\n",
            u_errorName(status));
        return EXIT_FAILURE;
    }

    /* consume input as UTF-32 units one by one */
    while ((c = u_fgetcx(in)) != U_EOF)
    {
        /* Decompose c to isolate its n combining character
         * codepoints. Saves them as UTF-16 code units.  FYI,
         * this function ignores the type of "norm" and always
         * denormalizes */
        n = unorm2_getDecomposition(
            norm, c, decomp, MAX_DECOMP_LEN, &status
        );

        if (U_FAILURE(status)) {
            fprintf(stderr,
                "unorm2_getDecomposition(): %s\n",
                u_errorName(status));
            u_fclose(in);
            return EXIT_FAILURE;
        }

        /* if c does not decompose and is not itself
         * a diacritical mark */
        if (n < 0 && ublock_getCode(c) !=
            UBLOCK_COMBINING_DIACRITICAL_MARKS)
            u_fputc(c, out);

        /* walk canonical decomposition, reuse c variable */
        for (i = 0; i < n; )
        {
            /* the U16_NEXT macro iterates over UChar (aka
             * UTF-16, advancing by one or two elements as
             * needed to get a codepoint. It saves the result
             * in UTF-32. The macro updates i and c. */
            U16_NEXT(decomp, i, n, c);
            /* output only if not combining diacritical */
            if (ublock_getCode(c) !=
                UBLOCK_COMBINING_DIACRITICAL_MARKS)
                u_fputc(c, out);
        }
    }

    u_fclose(in);
    /* u_get_stdout() doesn't need to be u_fclose'd */
    return EXIT_SUCCESS;
}
#if defined(CALCULATE_BUILD)
#   pragma message("Build library and export stuff")
#   define CALCULATE_EXPORT __declspec (dllexport)
#else
#   pragma message("Use library and import stuff")
#   define CALCULATE_EXPORT __declspec (dllimport)
#endif

CALCULATE_EXPORT int Add(int a, int b);

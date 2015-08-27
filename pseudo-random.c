#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define SIZE (1 << 12)
static int marks[(SIZE * SIZE) >> 5];
static int colors[3];
static int cperm[3];

int main(int argc, char *argv[]) {
    int seed;
    if (argc > 1)
        seed = atoi(argv[1]);
    else
        seed = (uintmax_t) time(NULL) / (24 * 3600);
    if (seed < 0)
        seed = - seed;
    seed %= (SIZE * 6);
    fprintf(stderr, "Seed = %d\n", seed);

    cperm[0] = seed % 3;
    seed /= 3;
    cperm[1] = (cperm[0] + 1 + (seed % 2)) % 3;
    cperm[2] = (cperm[0] + 2 - (seed % 2)) % 3;
    seed /= 2;

    fprintf(stdout, "P6\n%d %d\n255\n", SIZE, SIZE);

    for (int i = (((SIZE * SIZE) >> 5) - 1); i >= 0; i--)
        marks[i] = 0;

    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            int u = x ^ (x >> 1);
            int v = y ^ (y >> 1);
            for (int i = 0; i < 3; i++)
                colors[i] = 0;
            for (int bit = 0; bit < 12; bit++) {
                int col = bit % 3;
                colors[col] <<= 2;
                int sh = 11 - bit;
                int ub = (u >> sh) & 1;
                int vb = (v >> sh) & 1;
                if (0 == ((seed >> bit) & 1))
                    colors[col] += ub + (vb << 1);
                else
                    colors[col] += (ub << 1) + vb;
            }
            for (int i = 0; i < 3; i++)
                fputc(colors[cperm[i]], stdout);
            int num = colors[cperm[0]] | (colors[cperm[1]] << 8) |
                (colors[cperm[2]] << 16);
            int index = num >> 5;
            marks[index] |= (1 << (num & 31));
        }
    }

    for (int i = (((SIZE * SIZE) >> 5) - 1); i >= 0; i--)
        if (-1 != marks[i])
            fprintf(stderr, "absent colors! %d %d", i, marks[i]);
}

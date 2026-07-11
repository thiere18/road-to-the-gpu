// void fill(void);                    // A[i][j] = i + j, once, before any timing
// long long sum_row_order(void);      // grand total, i-outer j-inner
// long long sum_col_order(void);      // same grand total, j-outer i-inner
// int main(void);                     // fill → time one → time other → print

#include <stdio.h>
#include <time.h>

#define SIZE 4096

int matrix[SIZE][SIZE];

void fill(void)
{
    for (int i = 0; i < SIZE; i++)
    {
        for (int j = 0; j < SIZE; j++)
        {
            matrix[i][j] = i + j;
        }
    }
}
long long sum_row_order(void)
{
    long long total = 0;
    for (int i = 0; i < SIZE; i++)
    {
        for (int j = 0; j < SIZE; j++)
        {
            total += matrix[i][j];
        }
    }
    return total;
}

long long sum_col_order(void)
{
    long long total = 0;
    for (int i = 0; i < SIZE; i++)
    {
        for (int j = 0; j < SIZE; j++)
        {
            total += matrix[j][i];
        }
    }
    return total;
}

int main(int argc, char const *argv[])
{
    fill();
    long long sum_row = sum_row_order();       // the thing being measured
    long long sum_col = sum_col_order();
    printf("---- %lld ----\n", sum_row);
    printf("---- %lld ----\n", sum_col);

    return 0;
}

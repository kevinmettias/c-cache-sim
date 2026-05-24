#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>

static void Trace_Placeholder_Test(void** state)
{
    (void)state;
}

int main(void)
{
    const struct CMUnitTest tests[] = {
        cmocka_unit_test(Trace_Placeholder_Test),
    };

    return cmocka_run_group_tests(tests, NULL, NULL);
}

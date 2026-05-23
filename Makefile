CC := cc
CFLAGS := -std=c11 -Wall -Wextra -Wpedantic -Werror -Iinclude
LDFLAGS :=
LDLIBS := -lcmocka

BUILD_DIR := build
SRC := src/cache_sim.c src/trace.c src/workloads.c
APP_SRC := src/main.c
APP := $(BUILD_DIR)/cache-sim

TEST_CACHE := $(BUILD_DIR)/test_cache_sim
TEST_TRACE := $(BUILD_DIR)/test_trace

.PHONY: all test clean dirs

all: $(APP)

dirs:
	@mkdir -p $(BUILD_DIR)

$(APP): $(SRC) $(APP_SRC) | dirs
	$(CC) $(CFLAGS) $(SRC) $(APP_SRC) -o $@ $(LDFLAGS)

$(TEST_CACHE): src/cache_sim.c tests/test_cache_sim.c | dirs
	$(CC) $(CFLAGS) src/cache_sim.c tests/test_cache_sim.c -o $@ $(LDFLAGS) $(LDLIBS)

$(TEST_TRACE): src/trace.c tests/test_trace.c | dirs
	$(CC) $(CFLAGS) src/trace.c tests/test_trace.c -o $@ $(LDFLAGS) $(LDLIBS)

test: $(TEST_CACHE) $(TEST_TRACE)
	$(TEST_CACHE)
	$(TEST_TRACE)

clean:
	rm -rf $(BUILD_DIR)

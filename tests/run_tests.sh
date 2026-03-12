#!/usr/bin/env bash

# Find executable
if [ -f "build/Clox" ]; then
    EXECUTABLE="build/Clox"
elif [ -f "cmake-build-debug/Clox" ]; then
    EXECUTABLE="cmake-build-debug/Clox"
elif [ -f "cmake-build-release/Clox" ]; then
    EXECUTABLE="cmake-build-release/Clox"
elif [ -f "Clox" ]; then
    EXECUTABLE="Clox"
else
    echo "Error: Could not find 'Clox' executable. Please build the project first."
    exit 1
fi

echo "Using executable: $EXECUTABLE"

TESTS_DIR="tests"
PASSED=0
FAILED=0
MISSING_EXPECTED=0

# Iterate through all test files (excluding .expected and other non-test files)
find "$TESTS_DIR" -type f ! -name "*.expected" ! -name "*.sh" ! -name ".DS_Store" | while read TEST_FILE; do
    EXPECTED_FILE="${TEST_FILE}.expected"
    
    if [ ! -f "$EXPECTED_FILE" ]; then
        echo "[WARN] Missing expected output for: $TEST_FILE"
        MISSING_EXPECTED=$((MISSING_EXPECTED + 1))
        continue
    fi
    
    # Run the test and capture output
    OUTPUT_FILE=$(mktemp)
    ERROR_FILE=$(mktemp)
    
    # Run the executable, capture stdout and stderr, with a timeout
    if command -v timeout >/dev/null 2>&1; then
        timeout 5 "./$EXECUTABLE" "$TEST_FILE" > "$OUTPUT_FILE" 2> "$ERROR_FILE"
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
            echo "[FAIL] $TEST_FILE - TIMEOUT"
            FAILED=$((FAILED + 1))
            rm "$OUTPUT_FILE" "$ERROR_FILE"
            continue
        fi
    else
        "./$EXECUTABLE" "$TEST_FILE" > "$OUTPUT_FILE" 2> "$ERROR_FILE"
        EXIT_CODE=$?
    fi

    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 65 ] && [ $EXIT_CODE -ne 70 ]; then
        # Check if the error is just compilation error which is expected in some tests
        if ! grep -q "Compile error" "$ERROR_FILE"; then
            echo "[FAIL] $TEST_FILE"
            echo "  Program crashed with return code: $EXIT_CODE"
            if [ -s "$ERROR_FILE" ]; then
                echo "  Stderr:"
                cat "$ERROR_FILE" | sed 's/^/    /'
            fi
            FAILED=$((FAILED + 1))
            rm "$OUTPUT_FILE" "$ERROR_FILE"
            continue
        fi
    fi

    # The expected output might not include tracing logs. 
    # Clox seems to print debug logs like `0x... allocate...` when TRACE_EXECUTION, LOG_GC, etc are on.
    # To compare properly, we should either strip these logs or ensure the executable is built without them.
    # Currently, let's just diff them directly.
    # We will ignore leading/trailing whitespace and empty lines for a more robust comparison
    
    DIFF_OUTPUT=$(diff -u -w -B "$EXPECTED_FILE" "$OUTPUT_FILE")
    
    if [ $? -eq 0 ]; then
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] $TEST_FILE"
        echo "  Output differs from expected:"
        echo "$DIFF_OUTPUT" | sed 's/^/    /'
        FAILED=$((FAILED + 1))
    fi
    
    rm "$OUTPUT_FILE" "$ERROR_FILE"
done

# The while read loop runs in a subshell, so variables like PASSED/FAILED aren't visible outside.
# Let's write the results to a temporary file to keep count
TEMP_RESULT=$(mktemp)
echo "0,0,0" > "$TEMP_RESULT"

find "$TESTS_DIR" -type f ! -name "*.expected" ! -name "*.sh" ! -name ".DS_Store" | while read TEST_FILE; do
    EXPECTED_FILE="${TEST_FILE}.expected"
    
    if [ ! -f "$EXPECTED_FILE" ]; then
        echo "[WARN] Missing expected output for: $TEST_FILE"
        IFS=',' read P F M < "$TEMP_RESULT"
        echo "$P,$F,$((M + 1))" > "$TEMP_RESULT"
        continue
    fi
    
    # ...
    OUTPUT_FILE=$(mktemp)
    ERROR_FILE=$(mktemp)
    
    if command -v timeout >/dev/null 2>&1; then
        timeout 5 "./$EXECUTABLE" "$TEST_FILE" > "$OUTPUT_FILE" 2> "$ERROR_FILE"
        EXIT_CODE=$?
    else
        "./$EXECUTABLE" "$TEST_FILE" > "$OUTPUT_FILE" 2> "$ERROR_FILE"
        EXIT_CODE=$?
    fi

    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 65 ] && [ $EXIT_CODE -ne 70 ]; then
        if ! grep -q "Compile error" "$ERROR_FILE"; then
            echo "[FAIL] $TEST_FILE"
            echo "  Program crashed with return code: $EXIT_CODE"
            if [ -s "$ERROR_FILE" ]; then
                echo "  Stderr:"
                cat "$ERROR_FILE" | sed 's/^/    /'
            fi
            IFS=',' read P F M < "$TEMP_RESULT"
            echo "$P,$((F + 1)),$M" > "$TEMP_RESULT"
            rm "$OUTPUT_FILE" "$ERROR_FILE"
            continue
        fi
    fi
    
    # The actual output test is the diff
    DIFF_OUTPUT=$(diff -u -w -B "$EXPECTED_FILE" "$OUTPUT_FILE")
    
    if [ $? -eq 0 ]; then
        # echo "[PASS] $TEST_FILE"
        IFS=',' read P F M < "$TEMP_RESULT"
        echo "$((P + 1)),$F,$M" > "$TEMP_RESULT"
    else
        echo "[FAIL] $TEST_FILE"
        echo "  Output differs from expected:"
        echo "$DIFF_OUTPUT" | sed 's/^/    /'
        IFS=',' read P F M < "$TEMP_RESULT"
        echo "$P,$((F + 1)),$M" > "$TEMP_RESULT"
    fi
    
    rm "$OUTPUT_FILE" "$ERROR_FILE"
done

IFS=',' read PASSED FAILED MISSING_EXPECTED < "$TEMP_RESULT"
rm "$TEMP_RESULT"

echo ""
echo "--- Summary ---"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
if [ "$MISSING_EXPECTED" -gt 0 ]; then
    echo "Missing .expected: $MISSING_EXPECTED"
fi

if [ "$FAILED" -gt 0 ]; then
    exit 1
else
    exit 0
fi

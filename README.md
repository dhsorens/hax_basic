# HAX Basic - Functional Counter for Formal Verification

This is a simple Rust project demonstrating a basic counter implementation written in a functional style, designed to be amenable to formal verification.

## Overview

The counter module provides pure, stateless functions for counter operations. All functions are deterministic and side-effect-free, making them ideal candidates for formal verification using tools like HAX (High-Assurance eXecution) or other formal verification frameworks.

## Structure

- `src/lib.rs` - Contains the counter implementation with pure functions
- `Cargo.toml` - Rust project configuration

## Functions

### Core Operations

- **`new_counter()`** - Creates a new counter initialized to zero
- **`increment(c)`** - Increments a counter by one
- **`decrement(c)`** - Decrements a counter by one
- **`add(c, n)`** - Adds `n` to the counter
- **`subtract(c, n)`** - Subtracts `n` from the counter
- **`reset(c)`** - Resets the counter to zero

## Properties for Formal Verification

Each function includes documented properties that can be formally verified:

### Identity Properties
- `new_counter() == 0`
- `reset(c) == 0`
- `add(c, 0) == c`
- `subtract(c, 0) == c`

### Inverse Properties
- `decrement(increment(c)) == c` (when no overflow occurs)
- `increment(decrement(c)) == c` (when no underflow occurs)

### Composition Properties
- `increment(increment(c)) == increment(c) + 1`
- `add(c, 1) == increment(c)`
- `subtract(c, 1) == decrement(c)`
- `add(add(c, n), m) == add(c, n + m)` (when no overflow)
- `subtract(subtract(c, n), m) == subtract(c, n + m)` (when no underflow)

### Boundary Properties
- `increment(u32::MAX) == 0` (wrapping behavior)
- `decrement(0) == u32::MAX` (wrapping behavior)

## Running Tests

To run the unit tests:

```bash
cargo test
```

## Formal Verification Approach

This code is structured to be verified using formal methods:

1. **Pure Functions**: All functions are pure (no side effects, deterministic)
2. **Type Safety**: Uses Rust's type system for basic guarantees
3. **Documented Properties**: Each function includes properties that can be verified
4. **Simple Operations**: Basic arithmetic operations that are easy to reason about

### Potential Verification Targets

- **Correctness**: Verify that functions behave as specified
- **Invariants**: Prove that certain properties always hold
- **Safety**: Verify no undefined behavior (handled via wrapping arithmetic)
- **Equivalence**: Prove that different compositions are equivalent

### Example Verification Goals

1. Prove that `increment` and `decrement` are inverse operations (modulo wrapping)
2. Prove that `add(c, n)` is equivalent to `n` successive `increment` calls
3. Prove that `reset` always returns zero regardless of input
4. Verify wrapping behavior at boundaries

## Notes

- The implementation uses `wrapping_add` and `wrapping_sub` to handle overflow/underflow deterministically
- All functions are pure and stateless, making them ideal for formal verification
- The counter type is `u32`, but the design can be generalized to other numeric types

## Future Enhancements

Potential additions for more complex verification:
- Bounded counter with overflow checks
- Counter with maximum value constraints
- Stateful counter with history tracking
- Integration with HAX or other formal verification tools


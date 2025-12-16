/// A simple counter module written in functional style for formal verification.
/// 
/// This module provides pure functions for counter operations that are
/// amenable to formal verification techniques.

use hax_lib as hax;

/// Represents a counter value.
pub type Counter = u32;

/// Creates a new counter initialized to zero.
/// 
/// # Returns
/// A counter value of 0.
/// 
/// # Properties
/// - `new_counter() == 0`
#[hax::ensures(|result| result == 0)]
#[hax::lean::before("@[simp, spec]")]
#[hax::lean::after(
    "-- Specification of new_counter
theorem Hax_basic.new_counter_spec :
  ⦃ ⌜ True ⌝ ⦄ -- Precondition (always true here)
  (Hax_basic.new_counter Rust_primitives.Hax.Tuple0.mk) -- The function call
  ⦃ ⇓ result => ⌜ Hax_basic._.ensures Rust_primitives.Hax.Tuple0.mk result = pure true ⌝ ⦄  -- Postcondition
  := by
  mvcgen [Hax_basic.new_counter, Hax_basic._.ensures]
"
)]
pub fn new_counter() -> Counter {
    0
}

/// Increments a counter by one.
/// 
/// # Arguments
/// * `c` - The current counter value
/// 
/// # Returns
/// The counter value incremented by 1.
/// 
/// # Properties
/// - `increment(new_counter()) == 1`
/// - `increment(increment(c)) == increment(c) + 1`
/// - `increment(c) == c + 1`
/// TODO #[hax::ensures(|result| result == c.wrapping_add(1))]
pub fn increment(c: Counter) -> Counter {
    c.wrapping_add(1)
}

/// Decrements a counter by one.
/// 
/// # Arguments
/// * `c` - The current counter value
/// 
/// # Returns
/// The counter value decremented by 1 (wraps around on underflow).
/// 
/// # Properties
/// - `decrement(increment(c)) == c` (when no overflow occurs)
/// - `decrement(new_counter()) == u32::MAX`
/// TODO #[hax::ensures(|result| result == c.wrapping_sub(1))]
pub fn decrement(c: Counter) -> Counter {
    c.wrapping_sub(1)
}

/// Adds a value to the counter.
/// 
/// # Arguments
/// * `c` - The current counter value
/// * `n` - The value to add
/// 
/// # Returns
/// The counter value with `n` added (wraps around on overflow).
/// 
/// # Properties
/// - `add(c, 0) == c`
/// - `add(c, 1) == increment(c)`
/// - `add(add(c, n), m) == add(c, n + m)` (when no overflow)
/// TODO #[hax::ensures(|result| result == c.wrapping_add(n))]
pub fn add(c: Counter, n: Counter) -> Counter {
    c.wrapping_add(n)
}

/// Subtracts a value from the counter.
/// 
/// # Arguments
/// * `c` - The current counter value
/// * `n` - The value to subtract
/// 
/// # Returns
/// The counter value with `n` subtracted (wraps around on underflow).
/// 
/// # Properties
/// - `subtract(c, 0) == c`
/// - `subtract(c, 1) == decrement(c)`
/// - `subtract(subtract(c, n), m) == subtract(c, n + m)` (when no underflow)
/// TODO #[hax::ensures(|result| result == c.wrapping_sub(n))]
pub fn subtract(c: Counter, n: Counter) -> Counter {
    c.wrapping_sub(n)
}

/// Resets the counter to zero.
/// 
/// # Arguments
/// * `c` - The current counter value
/// 
/// # Returns
/// Always returns 0.
/// 
/// # Properties
/// - `reset(c) == new_counter()`
/// - `reset(c) == 0`
/// TODO #[hax::ensures(|result| result == 0)]
pub fn reset(_c: Counter) -> Counter {
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_counter() {
        assert_eq!(new_counter(), 0);
    }

    #[test]
    fn test_increment() {
        assert_eq!(increment(0), 1);
        assert_eq!(increment(5), 6);
        assert_eq!(increment(increment(0)), 2);
    }

    #[test]
    fn test_decrement() {
        assert_eq!(decrement(1), 0);
        assert_eq!(decrement(5), 4);
    }

    #[test]
    fn test_increment_decrement_inverse() {
        let c = 42;
        assert_eq!(decrement(increment(c)), c);
    }

    #[test]
    fn test_add() {
        assert_eq!(add(0, 0), 0);
        assert_eq!(add(5, 3), 8);
        assert_eq!(add(0, 1), increment(0));
    }

    #[test]
    fn test_subtract() {
        assert_eq!(subtract(5, 3), 2);
        assert_eq!(subtract(5, 1), decrement(5));
    }

    #[test]
    fn test_reset() {
        assert_eq!(reset(0), 0);
        assert_eq!(reset(100), 0);
        assert_eq!(reset(42), new_counter());
    }

    #[test]
    fn test_wrapping_behavior() {
        // Test overflow
        assert_eq!(increment(u32::MAX), 0);
        // Test underflow
        assert_eq!(decrement(0), u32::MAX);
    }
}


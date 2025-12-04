
-- Experimental lean backend for Hax
-- The Hax prelude library can be found in hax/proof-libs/lean
import Hax
import Std.Tactic.Do
import Std.Do.Triple
import Std.Tactic.Do.Syntax
open Std.Do
open Std.Tactic

set_option mvcgen.warning false
set_option linter.unusedVariables false

--  A simple counter module written in functional style for formal verification.
--
--  This module provides pure functions for counter operations that are
--  amenable to formal verification techniques.
--  Represents a counter value.
abbrev Hax_basic.Counter := u32

--  Creates a new counter initialized to zero.
--
--  # Returns
--  A counter value of 0.
--
--  # Properties
--  - `new_counter() == 0`
def Hax_basic.new_counter (_ : Rust_primitives.Hax.Tuple0) : RustM u32 := do
  (pure (0 : u32))

--  Increments a counter by one.
--
--  # Arguments
--  * `c` - The current counter value
--
--  # Returns
--  The counter value incremented by 1.
--
--  # Properties
--  - `increment(new_counter()) == 1`
--  - `increment(increment(c)) == increment(c) + 1`
--  - `increment(c) == c + 1`
def Hax_basic.increment (c : u32) : RustM u32 := do
  (Core.Num.Impl_8.wrapping_add c (1 : u32))

--  Decrements a counter by one.
--
--  # Arguments
--  * `c` - The current counter value
--
--  # Returns
--  The counter value decremented by 1 (wraps around on underflow).
--
--  # Properties
--  - `decrement(increment(c)) == c` (when no overflow occurs)
--  - `decrement(new_counter()) == u32::MAX`
def Hax_basic.decrement (c : u32) : RustM u32 := do
  (Core.Num.Impl_8.wrapping_sub c (1 : u32))

--  Adds a value to the counter.
--
--  # Arguments
--  * `c` - The current counter value
--  * `n` - The value to add
--
--  # Returns
--  The counter value with `n` added (wraps around on overflow).
--
--  # Properties
--  - `add(c, 0) == c`
--  - `add(c, 1) == increment(c)`
--  - `add(add(c, n), m) == add(c, n + m)` (when no overflow)
def Hax_basic.add (c : u32) (n : u32) : RustM u32 := do
  (Core.Num.Impl_8.wrapping_add c n)

--  Subtracts a value from the counter.
--
--  # Arguments
--  * `c` - The current counter value
--  * `n` - The value to subtract
--
--  # Returns
--  The counter value with `n` subtracted (wraps around on underflow).
--
--  # Properties
--  - `subtract(c, 0) == c`
--  - `subtract(c, 1) == decrement(c)`
--  - `subtract(subtract(c, n), m) == subtract(c, n + m)` (when no underflow)
def Hax_basic.subtract (c : u32) (n : u32) : RustM u32 := do
  (Core.Num.Impl_8.wrapping_sub c n)

--  Resets the counter to zero.
--
--  # Arguments
--  * `c` - The current counter value
--
--  # Returns
--  Always returns 0.
--
--  # Properties
--  - `reset(c) == new_counter()`
--  - `reset(c) == 0`
def Hax_basic.reset (_c : u32) : RustM u32 := do (pure (0 : u32))

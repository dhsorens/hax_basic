
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

--  Represents a counter value.
abbrev Hax_basic.Counter := u32

def Hax_basic._.future
  (T : Type) (x : T)
  : RustM (Rust_primitives.Hax.Tuple2 T T)
  := do
  let hax_temp_output : T := x;
  (pure (Rust_primitives.Hax.Tuple2.mk x hax_temp_output))

def Hax_basic._.ensures
  (_ : Rust_primitives.Hax.Tuple0)
  (result : u32)
  : RustM Bool
  := do
  (Rust_primitives.Hax.Machine_int.eq result (0 : u32))

@[simp, spec]

--  Creates a new counter initialized to zero.
--
--  # Returns
--  A counter value of 0.
--
--  # Properties
--  - `new_counter() == 0`
def Hax_basic.new_counter (_ : Rust_primitives.Hax.Tuple0) : RustM u32 := do
  (pure (0 : u32))

-- Specification of new_counter
theorem Hax_basic.new_counter_spec :
  ⦃ ⌜ True ⌝ ⦄ -- Precondition (always true here)
  (Hax_basic.new_counter Rust_primitives.Hax.Tuple0.mk) -- The function call
  ⦃ ⇓ result => ⌜ Hax_basic._.ensures Rust_primitives.Hax.Tuple0.mk result = pure true ⌝ ⦄  -- Postcondition
  := by
  mvcgen [Hax_basic.new_counter, Hax_basic._.ensures]

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
--  #[hax::ensures(|result| result == c.wrapping_add(1))]
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
--  #[hax::ensures(|result| result == c.wrapping_sub(1))]
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
--  #[hax::ensures(|result| result == c.wrapping_add(n))]
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
--  #[hax::ensures(|result| result == c.wrapping_sub(n))]
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
--  #[hax::ensures(|result| result == 0)]
def Hax_basic.reset (_c : u32) : RustM u32 := do (pure (0 : u32))

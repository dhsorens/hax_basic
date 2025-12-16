# Hax Workflow for Formal Verification

This document describes the iterative workflow for using Hax to formally verify Rust code with Lean.

## Overview

The Hax workflow enables you to:
1. Annotate Rust functions with specifications (pre/post conditions)
2. Extract Rust code to Lean for theorem proving
3. Write and prove theorems in Lean
4. Embed proven theorems back into Rust code

This creates a cycle where specifications drive verification, and proven theorems become part of your codebase.

## Step 1: Annotate Functions with Pre- and Post-Conditions

Add Hax annotations to your Rust functions to generate helper functions in Lean.

### Example: Basic Postcondition

```rust
#[hax::ensures(|result| result == 0)]
pub fn new_counter() -> Counter {
    0
}
```

### Example: Postcondition with Parameters

```rust
#[hax::ensures(|result| result == c.wrapping_add(1))]
pub fn increment(c: Counter) -> Counter {
    c.wrapping_add(1)
}
```

### Example: Precondition and Postcondition

```rust
#[hax::requires(c < u32::MAX)]
#[hax::ensures(|result| result == c + 1)]
pub fn safe_increment(c: Counter) -> Counter {
    c + 1
}
```

### Additional Annotations

- `#[hax::lean::before("...")]` - Adds Lean code before the function definition
- `#[hax::lean::after("...")]` - Adds Lean code after the function definition (used for proven theorems)

## Step 2: Extract to Lean and Generate Helper Functions

Run Hax to extract your Rust code to Lean:

```bash
cargo hax into lean
```

This generates:
- **Function definitions** in `proofs/lean/extraction/Hax_basic.lean`
- **Helper functions** like `Hax_basic._.ensures` for postconditions
- **Helper functions** like `Hax_basic._.requires` for preconditions

### Generated Helper Functions

For a function with `#[hax::ensures(|result| result == 0)]`, Hax generates:

```lean
def Hax_basic._.ensures
  (_ : Rust_primitives.Hax.Tuple0)
  (result : u32)
  : RustM Bool
  := do
  (Rust_primitives.Hax.Machine_int.eq result (0 : u32))
```

This helper function encodes your postcondition and can be used in theorem statements.

## Step 3: Write and Prove Theorems in Lean

Open the generated Lean file (`proofs/lean/extraction/Hax_basic.lean`) and write theorems about your functions.

### Example: Specification Theorem

```lean
-- Specification of new_counter
theorem Hax_basic.new_counter_spec :
  ⦃ ⌜ True ⌝ ⦄ -- Precondition (always true here)
  (Hax_basic.new_counter Rust_primitives.Hax.Tuple0.mk) -- The function call
  ⦃ ⇓ result => ⌜ Hax_basic._.ensures Rust_primitives.Hax.Tuple0.mk result = pure true ⌝ ⦄  -- Postcondition
  := by
  mvcgen [Hax_basic.new_counter, Hax_basic._.ensures]
```

### Theorem Structure

Theorems use Hoare triple syntax:
- `⦃ P ⦄` - Precondition
- `(function_call)` - The computation
- `⦃ ⇓ result => Q ⦄` - Postcondition (result satisfies Q)

### Proving Theorems

Use Lean tactics to prove your theorems:
- `mvcgen` - Automatic proof generation for simple cases
- `simp` - Simplification
- `rw` - Rewriting
- `apply` - Apply lemmas
- Manual proof construction for complex cases

### Example: More Complex Theorem

```lean
theorem Hax_basic.increment_decrement_inverse (c : u32) :
  ⦃ ⌜ True ⌝ ⦄
  (do
    let r1 ← Hax_basic.increment c
    Hax_basic.decrement r1)
  ⦃ ⇓ result => ⌜ result = c ⌝ ⦄
  := by
  -- Your proof here
```

## Step 4: Embed Proven Theorems Back into Rust

Once you've proven a theorem in Lean, copy it back into your Rust code using the `#[hax::lean::after(...)]` attribute.

### Example: Embedding a Proven Theorem

```rust
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
```

### Benefits of Embedding Theorems

1. **Version Control**: Theorems are stored with the code they verify
2. **Regeneration**: Running `cargo hax into lean` will include your proven theorems
3. **Documentation**: Theorems serve as formal documentation
4. **Reproducibility**: Anyone can regenerate the Lean code with the same theorems

## Complete Workflow Cycle

```
┌─────────────────────────────────────┐
│ 1. Annotate Rust functions          │
│    with #[hax::ensures(...)]        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ 2. Run: cargo hax into lean          │
│    Generates Lean code + helpers    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ 3. Write theorems in Lean file      │
│    Prove them using Lean tactics    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ 4. Copy proven theorems back to     │
│    Rust using #[hax::lean::after]   │
└──────────────┬──────────────────────┘
               │
               ▼
         (Repeat as needed)
```

## Best Practices

1. **Start Simple**: Begin with basic postconditions and simple proofs
2. **Incremental Development**: Add one annotation at a time, verify it works
3. **Use Helper Functions**: The generated `_.ensures` and `_.requires` functions make theorem statements cleaner
4. **Document Theorems**: Add comments explaining what each theorem proves
5. **Version Control**: Commit both Rust and Lean files together

## Common Patterns

### Pattern: Identity Property

```rust
#[hax::ensures(|result| result == c)]
pub fn identity(c: Counter) -> Counter {
    c
}
```

### Pattern: Composition Property

```rust
#[hax::ensures(|result| result == c.wrapping_add(n))]
pub fn add(c: Counter, n: Counter) -> Counter {
    c.wrapping_add(n)
}
```

### Pattern: Inverse Operations

Prove that `decrement(increment(c)) == c` (modulo wrapping).

## Troubleshooting

- **Helper functions not generated**: Ensure annotations are correct and run `cargo hax into lean` again
- **Theorems don't compile**: Check that function names and types match the generated code
- **Proofs fail**: Start with simpler properties, use `mvcgen` for automatic proofs when possible

## See Also

- Hax documentation: [hax-rs.org](https://hax-rs.org)
- Lean 4 documentation: [leanprover.github.io](https://leanprover.github.io)
- Generated Lean files: `proofs/lean/extraction/Hax_basic.lean`

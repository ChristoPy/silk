## Features

### Comment
- **Single line**
    ```js
    // code comment
    ```
- **Multi line**
    ```js
    // code comment
    // code comment
    // code comment
    ```

### Variable declaration

At **top level** (outside any function) you must use **`const`** only. Inside a **function** you can use **`const`** or **`let`**.

- **Boolean**
    ```js
    let loggedIn = true
    let sideBarOpen = false
    ```
- **String**
    ```js
    let name = "Kyle"
    ```
- **Number**
    ```js
    let age = 32
    ```
- **Arithmetic (variable declarations only)**  
    ```js
    const a = 1 + 2
    const b = 10 - 3
    let c = a + b
    const d = 1 + 2 * 3   // 1 + (2 * 3)
    const e = (1 + 2) * 3 // grouped
    const half = 100 / 2
    ```
- **Null**
    ```js
    let value = null
    const maybe = null
    ```
- **Map**
    ```js
    let user = {name: "Kyle", age: 32}
    ```
- **List**
    ```js
    let fruits = ["banana", "apple", "avocado"]
    ```
- **List index access**  
  You can read an element by index with `[expression]`. The index must be a number: a literal, a variable that was assigned a number literal, or an object property that holds a number (e.g. `obj.index`).
    ```js
    const i = 0
    const items = [10, 20, 30]
    const first = items[i]
    const config = { index: 1 }
    const second = items[config.index]
    ```
- **References**
    ```js
    let basket = fruits
    ```
- **Dynamic values**
    ```js
    let name = getName(user)
    let user = {name: "Kyle", age: 32, plan: getPlan()}
    let names = [getNames()]
    ```

### Functions
- **Declaration**
  ```js
  function myFunction() {}
  ```

- **Declaration with parameters**
  ```js
  function sum(a, b) {}
  ```

- **Call with parameters**
  ```js
  doSomething(1)
  doSomething(true)
  doSomething(false)
  doSomething("Kyle")
  doSomething(user)
  doSomething(getThingFirst())
  ```

### Control flow (Only inside functions)
- **Return**
  ```js
  return "Hello, World!"
  ```

### Modules
- **Import**  
  Imports are only allowed at the top of the file (before any other statement). You can import standard library modules (e.g. `std/io`, `std/string`, `std/number`, `std/array`, `std/object`).
  ```js
  import IO from "std/io"
  import String from "std/string"
  ```
- **Export**
  ```js
  export function main() {}
  ```
- **Standard library**  
  The standard library provides modules for I/O, built-in types (string, number, array, object), JSON, HTTP, time, environment variables, regex, math, and result (error handling). Import a module and call its functions via the alias you chose. All parsing and I/O helpers that can fail return a **Result** instead of throwing; use **std/result** to check success or error and to unwrap values.

  **std/io** (e.g. `import IO from "std/io"`)
  - `IO.print(value)` — print a value to the console

  **std/string** (e.g. `import String from "std/string"`)
  - `String.uppercase(s)` — uppercase copy of the string
  - `String.lowercase(s)` — lowercase copy
  - `String.trim(s)` — trim whitespace from both ends
  - `String.length(s)` — length of the string
  - `String.slice(s, start, end)` — substring from start to end
  - `String.includes(s, sub)` — whether the string contains the substring
  - `String.split(s, sep)` — split into an array by separator
  - `String.replace(s, from, to)` — replace first occurrence of `from` with `to`
  - `String.concat(a, b)` — concatenate two strings

  **std/number** (e.g. `import Number from "std/number"`)
  - `Number.round(n)` — round to nearest integer
  - `Number.floor(n)` — floor
  - `Number.ceil(n)` — ceiling
  - `Number.abs(n)` — absolute value
  - `Number.min(a, b)` — smaller of two numbers
  - `Number.max(a, b)` — larger of two numbers
  - `Number.parse(s)` — parse a string to a number; returns a Result (ok: parsed number, err: error message)

  **std/array** (e.g. `import Array from "std/array"`)
  - `Array.length(arr)` — length of the array
  - `Array.join(arr, sep)` — join elements with separator into a string
  - `Array.concat(a, b)` — concatenate two arrays
  - `Array.slice(arr, start, end)` — slice from start to end
  - `Array.indexOf(arr, elem)` — index of first occurrence of element, or -1
  - `Array.first(arr)` — first element
  - `Array.last(arr)` — last element

  **std/object** (e.g. `import Object from "std/object"`)
  - `Object.keys(obj)` — array of keys
  - `Object.values(obj)` — array of values
  - `Object.has(obj, key)` — whether the object has the key

  **std/json** (e.g. `import Json from "std/json"`)
  - `Json.parse(s)` — parse a JSON string; returns a Result (ok: object/array, err: error message)
  - `Json.stringify(value)` — serialize a value to JSON; returns a Result (ok: string, err: error message)

  **std/http** (e.g. `import Http from "std/http"`)
  - `Http.get(url)` — GET request; returns a Result whose value is a Promise of the response body (sync failures return err)
  - `Http.post(url, body)` — POST request; same Result shape

  **std/time** (e.g. `import Time from "std/time"`)
  - `Time.now()` — current timestamp in milliseconds
  - `Time.format(timestamp)` — format timestamp as ISO date string
  - `Time.parse(s)` — parse a date string; returns a Result (ok: timestamp, err: error message)

  **std/env** (e.g. `import Env from "std/env"`)
  - `Env.get(name)` — value of environment variable (empty string if missing)
  - `Env.has(name)` — whether the environment variable is set

  **std/regex** (e.g. `import Regex from "std/regex"`)
  - `Regex.match(s, pattern)` — whether the string matches the pattern; returns a Result (ok: boolean, err: invalid pattern message)
  - `Regex.replace(s, pattern, replacement)` — replace first match; returns a Result (ok: string, err: invalid pattern message)

  **std/math** (e.g. `import Math from "std/math"`)
  - `Math.random()` — random number between 0 and 1
  - `Math.sqrt(n)` — square root
  - `Math.pow(base, exp)` — base to the power of exp

  **std/result** (e.g. `import Result from "std/result"`)  
  Used to build and inspect Result values returned by parsing and I/O functions. A Result is either success `{ ok: true, value }` or error `{ ok: false, error }`.
  - `Result.ok(value)` — build a success result
  - `Result.err(error)` — build an error result
  - `Result.isOk(result)` — true if success
  - `Result.isErr(result)` — true if error
  - `Result.unwrapOr(result, default_value)` — return the value on success, or default_value on error

  Example (using Result with Json.parse):
  ```js
  import Result from "std/result"
  import Json from "std/json"

  function main() {
    const res = Json.parse("{}")
    if (Result.isOk(res)) {
      // use res.value
    } else {
      // use res.error
    }
    const data = Result.unwrapOr(res, {})
  }
  ```

  Example:
  ```js
  import IO from "std/io"
  import String from "std/string"

  function main() {
    IO.print(String.uppercase("hello"))
  }
  ```

## Compiler Rules
- **Duplicated identifier**

  You cannot create functions or variables with the same name in the same scope.  
  ```js
  import IO from "std/io"

  const IO = 1
  //   ╭─ ReferenceError: This identifier has already been declared.
  // 3 │  IO
  //   │  ^^
  //   • You can't declare a variable with this name. It has already been declared.
  ```
  Same for variables inside a function. Function parameters are variables, so you cannot declare the same name again inside that function.  
  ```js
  const name = "Anna"
  function greet(userName) {
    let userName = name
    return "Hello, " + userName
  }
  //   ╭─ ReferenceError: This identifier has already been declared.
  // 3 │  userName
  //   │  ^^^^^^^^
  //   • You can't declare a variable with this name. It has already been declared.
  ```
  This rule does not apply when the inner variable has a different scope (e.g. a parameter shadows an outer variable and you declare another variable with the outer name inside).  
  ```js
  const userName = "Anna"
  function greet(name) {
    let userName = name
    return "Hello, " + userName
  }
  ```
- **Reference to non defined value**  
  Silk reports a compile-time error when you use a name that has not been declared. This applies to variables, function calls, and function call arguments.*Did you mean: score?*
  ```js
  const a = b
  //   ╭─ ReferenceError: This identifier has not been declared.
  // 1 │  b
  //   │  ^
  //   • Cannot use this name. It has not been declared.
  ```
  When the name looks like a typo of a declared name (e.g. `scor` when `score` exists), Silk suggests: 
  ```js
  const score = 98
  function sumScore(value) {
    let newScore = scor + value // note the typo
    return newScore
  }
  //   ╭─ ReferenceError: This identifier has not been declared.
  // 3 │  scor
  //   │  ^^^^
  //   • Cannot use this name. It has not been declared.
  //   • Did you mean: score?
  ```
- **No dynamic values**  
  This rule is a boundary to prevent you from accessing a property in a dynamic value which (Silk) can't garantee it exists (yet).
  ```js
  import Module from "other-module"

  // a value returned from a function call cannot be accessed since its dynamic
  // and this makes more difficult to catch errors
  let name = Module.doSomething().dynamicValue
  //   ╭─ SyntaxError: I was not expecting this.
  // 6 │  .
  //   │  ^
  //   • Expected: Import, Let or Function
  ```
- **Reference to non defined nested value**
  Property access is checked against the shape of the object. You cannot read a property that was not defined on that object (or on a nested object along the path).  
  ```js
  const user = {
    name: "Jane",
    age: 25
  }
  function greet(name) {
    return "Hi, " + name
  }
  greet(user.lastName)
  //   ╭─ ReferenceError: This property has not been declared.
  // 8 │  lastName
  //   │  ^^^^^^^^
  //   • You can't use this variable as value. It does not exist.
  ```
  The same applies to module members: you can only call or use properties that exist on the imported module (e.g. `IO.print`, not `IO.other`).  
  ```js
  import IO from "std/io"

  IO.unknown("avocado")
  //   ╭─ ReferenceError: This property has not been declared.
  // 3 │  unknown
  //   │  ^^^^^^^
  //   • You can't use this variable as value. It does not exist.
  ```
- **Array index must be a number**
  The expression inside `arr[index]` must be a number: a number literal, a variable that was assigned a number literal, or a member expression that refers to an object property whose value is a number (e.g. `arr[obj.index]`). Using a string or other non-number index is a compile-time error.  
  ```js
  const config = { name: "x" }
  const list = [1, 2, 3]
  const bad = list[config.name]
  //   ╭─ ReferenceError: Index must be a number (literal or reference to a number).
  //   • ...
  ```

---

## Error reference

All compiler error IDs (as used in diagnostics and `util.errors_map`), with a short description and fix hint.

| ID | Kind | Description | Fix hint |
|----|------|-------------|---------|
| `unexpected_token` | Syntax | Unexpected token in source. | Check the grammar (e.g. expected expression, `)`, `}`). |
| `unexpected_eof` | Syntax | Input ended before a construct was complete. | Add the missing token (e.g. closing `)`, `}`, or expression). |
| `identifier_already_declared` | Reference | Name already declared in this scope. | Use a different name or remove the duplicate declaration. |
| `identifier_not_declared` | Reference | Name used but never declared. | Declare it (const/let/function) or fix the typo (see “Did you mean?”). |
| `module_not_found` | Reference | Import path does not match a known module. | Use a valid path (e.g. `"std/io"`) or fix the path string. |
| `cannot_export_function` | Reference | Only `main` can be exported. | Export `function main() { ... }` only. |
| `import_not_at_top_level` | Syntax | Import appears after another statement. | Move all imports to the top of the file. |
| `nested_property_not_declared` | Reference | Property does not exist on the object (or module). | Use a key that exists on the object or fix the typo (see “Did you mean?”). |
| `index_must_be_number` | Reference | Array index is not a number. | Use a number literal or a variable that holds a number. |
| `reserved_word_as_identifier` | Syntax | Reserved word used as variable/function name. | Use a different identifier. |
| `binary_only_in_declaration` | Syntax | Arithmetic used outside const/let initializer. | Use `+` `-` `*` `/` only in `const x = ...` or `let x = ...`. |
| `binary_operands_must_be_numbers` | Reference | Operands of `+` `-` `*` `/` must be numbers. | Use number literals or variables that hold numbers. |
| `else_without_if` | Syntax | `else` not immediately after an `if`. | Place `else` right after the closing `}` of the `if` block. |
| `wrong_argument_count` | Reference | Function called with wrong number of arguments. | Pass the exact number of arguments the function expects. |
| `return_path_inconsistent` | Reference | Some paths return a value, others do not. | Ensure every path returns a value (e.g. add return in else) or remove returns. |
| `unused_import` | Reference | Import alias is never used. | Remove the import or use the module (e.g. call a function from it). |
| `division_by_zero` | Reference | Divisor is the literal `0`. | Use a non-zero divisor or check the value before dividing. |
| `index_out_of_bounds` | Reference | Literal array index is out of bounds (negative or >= length). | Use an index between 0 and (array length - 1). |
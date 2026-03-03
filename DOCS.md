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
  Imports are only allowed at the top of the file (before any other statement). The only standard module currently supported is **`std/io`**.
  ```js
  import IO from "std/io"
  ```
- **Export**
  ```js
  export function main() {}
  ```
- **Standard module: std/io**  
  Use the `IO` object to call the standard I/O function `print`.
  ```js
  import IO from "std/io"

  function main() {
    IO.print("Hello, from Silk!")
    IO.print(42)
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
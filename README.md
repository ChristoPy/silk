# Silk
The Smooth JavaScript subset!  


# About and motivation
Silk is a programming language that was designed to reduce programming errors caused by the inherent flexibility and power of JavaScript. Although JavaScript is an incredibly powerful language that allows developers to do almost anything, its flexibility can sometimes lead to unexpected results and errors.

While TypeScript can help to reduce errors, Silk is not meant to replace JavaScript or TypeScript. TypeScript is primarily known for its type system, linting, and tooling capabilities, but it is also incredibly powerful in other ways, thanks to its compiler.

Silk takes a different approach from TypeScript. It encourages developers to write functional code while still taking advantage of the full power of JavaScript. If TypeScript were used instead, it could become overwhelming quickly, as TypeScript grows in the same way as JavaScript does.

It's worth noting that Silk is currently a small subset of JavaScript, designed to provide developers with a more focused and streamlined approach to coding in JavaScript.

## Features
### Comment
- [x] **Single line**
    ```js
    // code comment
    ```
- [x] **Multi line**
    ```js
    // code comment
    // code comment
    // code comment
    ```
### Variable declaration
- [x] **Boolean**
    ```js
    let loggedIn = true
    let sideBarOpen = false
    ```
- [x] **String**
    ```js
    let name = "Kyle"
    ```
- [x] **Number**
    ```js
    let age = 32
    ```
- [x] **Map**
    ```js
    let user = {name: "Kyle", age: 32}
    ```
- [x] **List**
    ```js
    let fruits = ["banana", "apple", "avocado"]
    ```
- [x] **References**
    ```js
    let basket = fruits
    ```
- [x] **Dynamic result**
    ```js
    let name = getName(user)
    ```
### Branching
- [x] **If (inside a function)**
  ```js
  if (name) {}
  ```
- [x] **Else if**
  ```js
  else if (name) {}
  ```
- [x] **Return (inside a function or if)**
  ```js
  return a + b
  ```

### Functions
- [x] **Declaration**
  ```js
  function doNothing() {}
  ```

- [x] **Declaration with parameters**
  ```js
  function sum(a, b) {}
  ```

- [x] **Call with one or many literal parameters**
  ```js
  doSomething(1)
  doSomething(true)
  doSomething(false)
  doSomething("Kyle")
  ```

- [x] **Call with one or many references**
  ```js
  pluralize(thing)
  ```
- [x] **Call with dynamic values**
  ```js
  pluralize(getThings())
  ```

### Math
- [ ] **Literals**
  ```js
  2 + 2
  ```
- [ ] **References**
  ```js
  price - discount
  ```
- [ ] **Complex**
  ```js
  (price * amount) - discount
  ```
### Modules
- [x] **Import**
  ```js
  import Math from "std/math"
  ```
- [ ] **Export**
  ```js
  export function main() {}
  ```
- [x] **Module usage**
  ```js
  import Math from "std/math"
  import String from "std/string"

  String.uppercase("avocado")
  let random = Math.random()
  let PI = Math.PI
  ```
## Compiler Rules
- [x] **Duplicated identifier**

  This rule makes impossible to create functions/variables with the same name.  
  ```js
  import Math from "std/math"

  let Math = 1
  //   ┌─ error: SyntaxError
  // 3 │  Math
  //   │  ^^^^ This identifier has already been declared.
  // You can't declare a variable with this name. It has already been declared.
  ```
  Same for variables inside a function.  
  Note that function parameters are variables, so they cannot be recreated inside of it too. Example:
  ```js
  let name = "Anna"
  function greet(userName) {
    let userName = String.titleCase(name)
    return "Hello, " + userName
  }
  //   ┌─ error: SyntaxError
  // 3 │  userName
  //   │  ^^^^^^^^ This identifier has already been declared.
  // You can't declare a variable with this name. It has already been declared.
  ```
  If the variable name is not created inside a function, this rule does not apply if the name exists outside of it.  
  ```js
  let userName = "Anna"
  function greet(name) {
    let userName = String.titleCase(name)
    return "Hello, " + userName
  }
  ```
- [x] **Reference to non defined value**  
  Silk will warn you about a non defined reference and won't compile. This rule applies for: variables, function calls, function calls parameters.
  ```js
  let a = b
  // Error:   ┌─ error: SyntaxError
  // 1 │  b
  //   │  ^ This identifier has not been declared.
  // You can't use this variable as value. It does not exist.
  ```
- [x] **No dynamic values**
  This rule is a boundary to prevent you from accessing a property in a dynamic value which (Silk) can't garantee it exists (yet).
  ```js
  import Module from "other-module"

  // a value returned from a function call cannot be accessed since its dynamic
  // and this makes more difficult to catch errors
  let name = Module.doSomething().dynamicValue
  ```

### Roadmap
- [x] Prevent name clashes
  - [x] Program scope
  - [x] Inner scopes
- [x] Prevent undefined errors
  - [x] Program scope
  - [x] Inner scopes
- [x] Warn about errors in a nicer way
- [ ] Sugest code fixes for errors
- [ ] Standard library
- [ ] Support imports
- [ ] CLI
  - [ ] Bootstrap a project
  - [ ] Compile the project to JS
- [ ] Documentation
- [ ] Silk <-> JS interoperability
- [ ] Small type system
- [ ] Editor integration (Language Server)
- [ ] Generate TS code
  - [ ] Generate types

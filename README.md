<div align="center" style="display:grid;place-items:center;">
<h1>Silk</h1>
<p>The Smooth JavaScript subset!</p>

[Roadmap](./ROADMAP.md)
</div>

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
### Control flow (Only inside functions)
- [ ] **Match**
  ```js
  match user.type {
    "admin" => "Hello, Admin!"
    "user" => "Hello, ${user.name}!"
    _ => "Hello, visitor!"
  }
  ```
- [x] **Return**
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
  import Math from "silk/math"
  ```
- [ ] **Export**
  ```js
  export function main() {}
  ```
- [x] **Module usage**
  ```js
  import Math from "silk/math"
  import String from "silk/string"

  String.uppercase("avocado")
  let random = Math.random()
  let PI = Math.PI
  ```
## Compiler Rules
- [x] **Duplicated identifier**

  This rule makes impossible to create functions/variables with the same name.  
  ```js
  import Math from "silk/math"

  let Math = 1
  //   ╭─ ReferenceError: This identifier has already been declared.
  // 3 │  Math
  //   │  ^^^^
  //   • You can't declare a variable with this name. It has already been declared.
  ```
  Same for variables inside a function.  
  Note that function parameters are variables, so they cannot be recreated inside of it too. Example:
  ```js
  let name = "Anna"
  function greet(userName) {
    let userName = String.titleCase(name)
    return "Hello, " + userName
  }
  //   ╭─ ReferenceError: This identifier has already been declared.
  // 3 │  userName
  //   │  ^^^^^^^^
  //   • You can't declare a variable with this name. It has already been declared.
  ```
  This rule does not apply if the variable name exists outside of it.  
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
  //   ╭─ ReferenceError: This identifier has not been declared.
  // 1 │  b
  //   │  ^
  // You can't use this variable as value. It does not exist.
  ```
  Example inside a function:
  ```js
  let score = 98
  function sumScore(value) {
    let newScore = scor + value // note the typo
    return newScore
  }
  //   ╭─ ReferenceError: This identifier has not been declared.
  // 3 │  scor
  //   │  ^^^^
  //   • You can't use this variable as value. It does not exist.
  ```
- [x] **No dynamic values**  
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
- [ ] **Reference to non defined nested value**  
  This rule prevents you from accessing a path in an object that does not exist.  
  ```js
  let user = {
    name: "Jane",
    age: 25
  }
  function greet(name) {
    return "Hi, " + name
  }
  greet(user.lastName)
  //   ╭─ SyntaxError: This property has not been declared.
  // 8 │  lastName
  //   │  ^^^^^^^^
  //   • You can't use this variable as value. It does not exist.
  ```
  Same when you call a nested function which is not a function or does not exist.  
  ```js
  import String from "silk/string"

  let fruit = String.upcase("avocado")
  //   ╭─ SyntaxError: This property has not been declared.
  // 3 │  upcase
  //   │  ^^^^^^
  //   • You can't use this variable as value. It does not exist.
  ```

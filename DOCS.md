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
- **Map**
    ```js
    let user = {name: "Kyle", age: 32}
    ```
- **List**
    ```js
    let fruits = ["banana", "apple", "avocado"]
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
  ```js
  import Math from "silk/math"
  ```
- **Export**
  ```js
  export function main() {}
  ```
- **Module usage (soon)**
  ```js
  import Math from "silk/math"
  import String from "silk/string"

  String.uppercase("avocado")
  let random = Math.random()
  let PI = Math.PI
  ```

## Compiler Rules
- **Duplicated identifier**

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
- **Reference to non defined value**  
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
- **Reference to non defined nested value (soon)**
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

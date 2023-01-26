# Parser
Attempt to write a parser for a programming language that looks like JavaScript.  
All code is valid JavaScript. But only a small subset of it is supported.

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
- [ ] **Map**
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
- [ ] **If**
  ```js
  if (name) {}
  ```
- [ ] **Else if**
  ```js
  else if (name) {}
  ```
- [ ] **Else**
  ```js
  else {}
  ```
- [ ] **Return (inside a function)**
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

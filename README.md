# Parser
Attempt to write a parser for a programming language that looks like JavaScript.  

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
- [x] **String**
    ```js
    let name = "Kyle"
    ```
- [x] **Number**
    ```js
    let age = 32
    ```
- [] **Map**
    ```js
    let user = {name: "Kyle", age: 32}
    ```
- [ ] **List**
    ```js
    let fruits = ["banana", "apple", "avocado"]
    ```
- [x] **References**
    ```js
    let basket = fruits
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
- [ ] **Return**
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
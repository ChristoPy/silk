<div align="center" style="display:grid;place-items:center;">
<h1>Silk  👘</h1>
<p>The Smooth JavaScript subset!</p>

[Roadmap](./ROADMAP.md) · [Docs](./DOCS.md)
</div>

---

Silk is a small programming language that compiles to JavaScript. It was designed to cut down on the kinds of mistakes that come from JavaScript’s flexibility—without replacing JavaScript or turning into a big, complex tool.

**A small subset.** Silk stays intentionally small. You get a focused set of constructs: constants and variables, functions, objects, arrays, and a few rules. No extra syntax to grow into. Less surface area, fewer surprises.

**Static analysis.** The compiler checks your program before it runs. It enforces that every name is declared before use, that you don’t use the same name twice in the same scope, and that object property access matches what you actually defined. If something is wrong, you hear about it at compile time.

**No undefined behavior.** You can’t reference a variable or function that doesn’t exist. You can’t read a property that isn’t on the object. Imports must be at the top; only known modules are allowed. The language is built so that whole class of “undefined at runtime” mistakes doesn’t exist.

**One way to do things.** Top level is `const` only. Inside functions you use `const` or `let`. No `var`, no hoisting, no “many correct styles.” One clear style keeps code readable and the rules easy to remember.

**No hoisting.** Declarations are not hoisted. What you see is the order the compiler sees. You declare, then you use. That keeps the mental model simple and avoids the classic “used before declared” confusion.

---

Silk is not meant to replace TypeScript. TypeScript adds a type system and a lot of power on top of JavaScript. Silk takes a different path: a small, strict subset that compiles to plain JavaScript and encourages straightforward, functional-style code. Less flexibility in the language, more predictability in your programs.

If that sounds like a breath of fresh air, check the [Docs](./DOCS.md) for the language and the [Roadmap](./ROADMAP.md) for what’s next.

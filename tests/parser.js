import Parser from "../src/parser.js";

const parser = new Parser();

console.log(JSON.stringify(parser.parse("1"), null, 2));
console.log(JSON.stringify(parser.parse("239303"), null, 2));

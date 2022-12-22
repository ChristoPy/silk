import Parser from "../src/parser.js";

const parser = new Parser();

console.log(JSON.stringify(parser.parse(" 1"), null, 2));
console.log(JSON.stringify(parser.parse("239303 "), null, 2));
console.log(JSON.stringify(parser.parse("   239303 "), null, 2));
console.log(JSON.stringify(parser.parse(`   
"Hello, World!"


`), null, 2));
console.log(JSON.stringify(parser.parse(`"   1 23  "`), null, 2));
console.log(JSON.stringify(parser.parse(`// comment`), null, 2));
console.log(JSON.stringify(parser.parse(`
// should be skipped
"Hello, World!"`), null, 2));
console.log(JSON.stringify(parser.parse('it breaks as should'), null, 2));

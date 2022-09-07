const fs = require('fs');
const path = require('path');
const childProcess = require('child_process');

outFile = 'testo.txt'
const folder = 'out';
const file = 'test.txt';
const out = path.join(folder, outFile);
const outText = fs.readFileSync(file, 'utf8');

if (!fs.existsSync(folder)) {
    fs.mkdirSync(folder);
}

childProcess.exec(`cd ${folder}; git init; git add -A; git commit -m "Initial Commit"`);

let t = '';
let count = 0;
for (let s of outText) {
    fs.writeFileSync(out, t);
    t += s;
    childProcess.exec(`cd ${folder}; git add -A; git commit -m "Add ${s} to ${outFile}"`);
    ++count;
}
console.log(`${count} characters written to ${out} with ${count} commits.`);

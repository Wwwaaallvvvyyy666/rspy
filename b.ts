import * as fs from 'fs';
import * as path from 'path';

import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const luamin = require('./luamin.js');

const inputFile = process.argv[2];

if (!inputFile) {
    console.log("Usage: npx tsx b.tsx <input> [output]");
    console.log("Example: npx tsx b.tsx tes.obf.lua");
    process.exit(1);
}

const outputFile = process.argv[3] || inputFile;

fs.readFile(inputFile, "utf8", (err, src) => {
    if (err) {
        console.error(`Error reading ${inputFile}: ${err.message}`);
        process.exit(1);
    }

    try {
        const beautified = luamin.Beautify(src, {
            RenameVariables: false,
            RenameGlobals: false,
            SolveMath: false,
            Indentation: '    ',
        });

        fs.writeFile(outputFile, beautified, (err) => {
            if (err) {
                console.error(`Error writing to ${outputFile}: ${err.message}`);
                process.exit(1);
            }
            console.log(`Saved beautified output to ${outputFile}`);
        });
    } catch (e: any) {
        const msg = (e && e.message) ? e.message : e;
        console.error(`Error beautifying: ${msg}`);
        process.exit(1);
    }
});
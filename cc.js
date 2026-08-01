const fs = require("fs");

function removeLuaComments(code) {
    code = code.replace(/--\[(=*)\[[\s\S]*?\]\1\]/g, "");

    code = code.replace(/--.*$/gm, "");

    return code;
}

const filePath = process.argv[2];

if (!filePath) {
    console.log("Usage: node cc.js <file.lua>");
    process.exit(1);
}

if (!fs.existsSync(filePath)) {
    console.error("File tidak ditemukan:", filePath);
    process.exit(1);
}

const code = fs.readFileSync(filePath, "utf8");
const cleaned = removeLuaComments(code);

fs.writeFileSync(filePath, cleaned, "utf8");

console.log("Komentar berhasil dihapus dari:", filePath);
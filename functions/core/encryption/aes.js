var aesjs = require('aes-js');
var AES = require("crypto-js/aes");
var SHA256 = require("crypto-js/sha256");
var CryptoJS = require("crypto-js");
 var crypto = require('crypto');


const decryptedText = (text) => {
    const encryptedText = 'z6cOu7YP61oZiXjMQ6r28w==';
    const key = aesjs.utils.utf8.toBytes('12345678912345678912345678912345');
    const iv = aesjs.utils.hex.toBytes('00000000000000000000000000000000'); // Default IV is all zeros
    const encryptedBytes = Buffer.from(encryptedText, 'base64');
    
    const aesCbc = new aesjs.ModeOfOperation(key, iv);
    const decryptedBytes = aesCbc.decrypt(encryptedBytes);
    
    const decryptedText = aesjs.utils.utf8.fromBytes(decryptedBytes);
    
    console.log(decryptedText);
    return decryptedText;

}

const newDecrypt = ()=>{
    const encryptedText = 'z6cOu7YP61oZiXjMQ6r28w==';
     
    const key = '12345678912345678912345678912345'; // 32-byte key for AES-256
    const iv = Buffer.alloc(16, 0); // 16-byte IV
    const encryptedData = Buffer.from(encryptedText, 'base64');
    
    // Create a decipher object
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    
    // Enable PKCS7 padding
    decipher.setAutoPadding(true);
    
    // Decrypt the data
    let decryptedData = decipher.update(encryptedData);
    decryptedData = Buffer.concat([decryptedData, decipher.final()]);
    
    console.log(decryptedData.toString());
   return decryptedText(decryptedData.toString())
}


module.exports = { decryptedText,newDecrypt };
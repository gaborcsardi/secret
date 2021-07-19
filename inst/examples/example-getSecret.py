import os
import struct


from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.primitives.serialization import load_der_public_key
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding


def loadPrivateKey():
    path = os.getenv("USER_KEY")
    if (path != None and os.path.exists(path)):
        pass
    elif (os.path.exists(os.getenv("HOME") + "/.ssh/id_rsa")):
        path = os.getenv("HOME") +"/.ssh/id_rsa"
    elif (os.path.exists(os.getenv("HOME") + "/.ssh/id_rsa.pem")):
        path = os.getenv("HOME") +"/.ssh/id_rsa.pem"
    else:
        raise Exception("No suitable user key found.")
    with open(path, 'rb') as keyFile:
        privateKey = serialization.load_pem_private_key(keyFile.read(), None,default_backend())
        return privateKey
      
vault=os.getenv("HOME") + "/.vault"
name="password"
secretFile = os.path.join(vault, "secrets", name, "secret.raw_nonR")
secretUserFile = os.path.join(vault, "secrets", name, os.getenv("USER") + ".enc_nonR")
privateKey = loadPrivateKey()

# Decrypt aes key
f = open(secretUserFile, 'rb')
encryptedAESKey = f.read()  
aesKey = privateKey.decrypt(encryptedAESKey,padding.PKCS1v15())
        
f = open(secretFile, 'rb')
encryptedData = f.read()  
iv = encryptedData[:16]
length = struct.unpack("<L", encryptedData[16:20])[0]
encryptedMessage = encryptedData[20:]
cipher = Cipher(algorithms.AES(aesKey), modes.CBC(iv))

# Decrypt
decryptor = cipher.decryptor()
res = decryptor.update(encryptedMessage) + decryptor.finalize()
message = res.decode()[:length]
print(message)



    

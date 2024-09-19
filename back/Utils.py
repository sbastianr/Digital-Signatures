import base64

import bcrypt
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from flask import jsonify

from Bd import BaseDeDatos
from RSAKeyGenerator import RSAKeyGenerator


# Almacenar el hash con salt
def generar_password_hash(password):
    # Generar la salt y crear el hash
    hash_con_salt = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hash_con_salt


# Verificar la contraseña
def verificar_password_hash(password, hash_almacenado):
    # Verificar si la contraseña coincide con el hash almacenado
    return bcrypt.checkpw(password.encode('utf-8'), hash_almacenado)


# Cargar la llave pública desde el texto plano
def cargar_llave_publica(public_key_text):
    return serialization.load_pem_public_key(
        public_key_text.encode('utf-8'),  # Convertir texto plano a bytes
        backend=default_backend()
    )


# Cargar la llave privada desde el archivo .pem
def cargar_llave_privada(private_key_pem):
    return serialization.load_pem_private_key(
        private_key_pem,
        password=None,  # Si la clave tiene contraseña, manejarla aquí
        backend=default_backend()
    )


# Verificar la firma usando la llave pública
def verificar_firma(public_key, mensaje, firma):
    try:
        public_key.verify(
            firma,
            mensaje,
            padding.PKCS1v15(),
            hashes.SHA256()
        )
        return True
    except Exception as e:
        print(f"Error al verificar: {e}")
        return False


# Convertir la firma (bytes) a una cadena en Base64
def firma_a_base64(firma):
    return base64.b64encode(firma).decode('utf-8')


# Convertir de Base64 a bytes (cuando necesites verificar la firma)
def base64_a_firma(firma_base64):
    return base64.b64decode(firma_base64)


def formatear_llave_privada(private_key_string):
    # Eliminar cualquier espacio o salto de línea innecesario
    private_key_string = private_key_string.replace('\\n', '').replace('\n', '').strip()
    private_key_string = private_key_string.replace('-----BEGIN RSA PRIVATE KEY-----', '').replace(
        '-----END RSA PRIVATE KEY-----', '').strip()

    # Reinsertar los saltos de línea cada 64 caracteres
    formatted_key = "-----BEGIN RSA PRIVATE KEY-----\n"
    for i in range(0, len(private_key_string), 64):
        formatted_key += private_key_string[i:i + 64] + '\n'
    formatted_key += "-----END RSA PRIVATE KEY-----\n"

    return formatted_key


# Firmar un mensaje simple con la llave privada
def firmar_mensaje(private_key, mensaje):
    try:
        firma = private_key.sign(
            mensaje,
            padding.PKCS1v15(),
            hashes.SHA256()
        )
    except Exception as e:
        print(f"Error al verificar: {e}")

    return firma


def registrarGoogle(name, email):
    bd = BaseDeDatos()

    rsa_generator = RSAKeyGenerator()
    rsa_generator.generate_keys()
    private_key_pem = rsa_generator.get_private_key_pem()
    public_key_pem = rsa_generator.get_public_key_pem()

    bd.guardar_usuario(nombre=name, telefono="0000",
                       email=email, password="google", public_key=public_key_pem)

    return private_key_pem

from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization


class RSAKeyGenerator:
    def __init__(self, key_size=2048):
        self.key_size = key_size
        self.private_key = None
        self.public_key = None

    def generate_keys(self):
        # Generate the private key
        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=self.key_size
        )
        # Generate the public key from the private key
        self.public_key = self.private_key.public_key()

    def get_private_key_pem(self):
        if self.private_key is None:
            raise ValueError("Keys not generated yet. Call generate_keys() first.")

        # Convert the private key to PEM format
        pem = self.private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.NoEncryption()
        )
        return pem.decode('utf-8')

    def get_public_key_pem(self):
        if self.public_key is None:
            raise ValueError("Keys not generated yet. Call generate_keys() first.")

        # Convert the public key to PEM format
        pem = self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        return pem.decode('utf-8')


# Example usage
if __name__ == '__main__':
    rsa_generator = RSAKeyGenerator()
    rsa_generator.generate_keys()

    private_key_pem = rsa_generator.get_private_key_pem()
    public_key_pem = rsa_generator.get_public_key_pem()

    print("Private Key:")
    print(private_key_pem)
    print("\nPublic Key:")
    print(public_key_pem)

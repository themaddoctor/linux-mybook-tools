/*
 * Cryptographic API.
 *
 * very simple cipher to permute each block of 16 bytes
 *
 * Thomas Kaeding <thomas.a.kaeding@gmail.com>, 20170313
 *
 * ---------------------------------------------------------------------------
 */

#include <linux/module.h>
#include <linux/crypto.h>

static u8 encvec[16], decvec[16];

int permute_setkey(struct crypto_tfm *tfm, const u8 *in_key, unsigned int key_len)
{
	int i;
	for (i=0;i<key_len;i++) {
	        encvec[2*i]   = in_key[i] >> 4;
		encvec[2*i+1] = in_key[i] & 0x0f;
	}
	for (i=0;i<16;i++)
		decvec[encvec[i]] = (u8)i;
	return 0;
}

static void permute_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
{
	int i;
	u8 temp[16];
	for (i=0;i<16;i++)
		temp[i] = in[i];
	for (i=0;i<16;i++)
		out[i] = temp[encvec[i]];
	return;
}

static void permute_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
{
	int i;
	u8 temp[16];
	for (i=0;i<16;i++)
		temp[i] = in[i];
	for (i=0;i<16;i++)
		out[i] = temp[decvec[i]];
	return;
}

static struct crypto_alg permute_alg = {
	.cra_name		=	"permute",
	.cra_driver_name	=	"permute",
	.cra_priority		=	100,
	.cra_flags		=	CRYPTO_ALG_TYPE_CIPHER,
	.cra_blocksize		=	16,
	.cra_ctxsize		=	0,
	.cra_alignmask		=	3,
	.cra_module		=	THIS_MODULE,
	.cra_u			=	{
		.cipher = {
			.cia_min_keysize	=	8,
			.cia_max_keysize	=	8,
			.cia_setkey		=	permute_setkey,
			.cia_encrypt		=	permute_encrypt,
			.cia_decrypt		=	permute_decrypt
		}
	}
};

static int __init permute_init(void)
{
	return crypto_register_alg(&permute_alg);
}

static void __exit permute_fini(void)
{
	crypto_unregister_alg(&permute_alg);
}

module_init(permute_init);
module_exit(permute_fini);

MODULE_DESCRIPTION("permutes the bytes of each 16-byte block");
MODULE_LICENSE("GPL");
MODULE_ALIAS("permute");

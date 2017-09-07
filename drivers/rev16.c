/*
 * Cryptographic API.
 *
 * very simple cipher to reverse each block of 16 bytes
 *
 * Thomas Kaeding, 20160120
 *
 * ---------------------------------------------------------------------------
 */

#include <linux/module.h>
#include <linux/crypto.h>

int rev16_setkey(struct crypto_tfm *tfm, const u8 *in_key, unsigned int key_len)
{
	return 0;
}

/* Why must we use a temp array?
 * Without it, only the first 8 bytes are affected. Why?
 */
static void rev16_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
{
	int i;
	u8 temp[16];
	for (i=0;i<16;i++)
		temp[i] = in[i];
	for (i=0;i<16;i++)
		out[i] = temp[15-i];
	return;
}

static struct crypto_alg rev16_alg = {
	.cra_name		=	"rev16",
	.cra_driver_name	=	"rev16",
	.cra_priority		=	100,
	.cra_flags		=	CRYPTO_ALG_TYPE_CIPHER,
	.cra_blocksize		=	16,
	.cra_ctxsize		=	0,
	.cra_alignmask		=	3,
	.cra_module		=	THIS_MODULE,
	.cra_u			=	{
		.cipher = {
			.cia_min_keysize	=	0,
			.cia_max_keysize	=	32,
			.cia_setkey		=	rev16_setkey,
			.cia_encrypt		=	rev16_encrypt,
			.cia_decrypt		=	rev16_encrypt
		}
	}
};

static int __init rev16_init(void)
{
	return crypto_register_alg(&rev16_alg);
}

static void __exit rev16_fini(void)
{
	crypto_unregister_alg(&rev16_alg);
}

module_init(rev16_init);
module_exit(rev16_fini);

MODULE_DESCRIPTION("reverses the bytes of each 16-byte block");
MODULE_LICENSE("GPL");
MODULE_ALIAS("rev16");

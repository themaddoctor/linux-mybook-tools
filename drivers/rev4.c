/*
 * Cryptographic API.
 *
 * very simple cipher to reverse each block of 4 bytes
 *
 * Thomas Kaeding, 20161119
 *
 * ---------------------------------------------------------------------------
 */

#include <linux/module.h>
#include <linux/algapi.h>

int rev4_setkey(struct crypto_tfm *tfm, const u8 *in_key, unsigned int key_len)
{
	return 0;
}

static void rev4_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
{
	int i;
	u8 temp[16];
	for (i=0;i<16;i++)
		temp[i] = in[i];
	for (i=0;i<4;i++) {
		out[0+4*i] = temp[3+4*i];
		out[1+4*i] = temp[2+4*i];
		out[2+4*i] = temp[1+4*i];
		out[3+4*i] = temp[0+4*i];
		}
	return;
}

static struct crypto_alg rev4_alg = {
	.cra_name		=	"rev4",
	.cra_driver_name	=	"rev4",
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
			.cia_setkey		=	rev4_setkey,
			.cia_encrypt		=	rev4_encrypt,
			.cia_decrypt		=	rev4_encrypt
		}
	}
};

static int __init rev4_init(void)
{
	return crypto_register_alg(&rev4_alg);
}

static void __exit rev4_fini(void)
{
	crypto_unregister_alg(&rev4_alg);
}

module_init(rev4_init);
module_exit(rev4_fini);

MODULE_DESCRIPTION("reverses the bytes of each 4-byte block");
MODULE_LICENSE("GPL");
MODULE_ALIAS("rev4");

/// Cybernetics defines

#define SECURITY_PROTOCOL "sec_protocol"
#define ENCODE_PROTOCOL "enc_protocol"
#define OPERATING_PROTOCOL	"op_protocol"

#define NO_PROTOCOL 0

/// Security protocols

///Those names mean nothing don't try to decipher these. They are defines because some cybernetics will be incompatible with eachother. treat those defines like software names.

#define SECURITY_NT1 	"nt1"
#define SECURITY_NT2 	"nt2"
#define SECURITY_NTX 	"ntx"
#define SECURITY_TMSP	"tmsp"
#define SECURITY_TOSP	"tosp"


/// Encode protocol

#define ENCODE_ENC1 "enc1"
#define ENCODE_ENC2 "enc2"
#define ENCODE_TENN "tenn"
#define ENCODE_CSEP "csep"


/// Operating protocol

#define OPERATING_NTOS "ntos"
#define OPERATING_TGMF "tgmf"
#define OPERATING_CSOF "csof"

#define AUGMENT_NO_REQ list(SECURITY_PROTOCOL = NO_PROTOCOL, ENCODE_PROTOCOL = NO_PROTOCOL, OPERATING_PROTOCOL = NO_PROTOCOL)
#define AUGMENT_NT_LOWLEVEL list(SECURITY_PROTOCOL = list(SECURITY_NT1), ENCODE_PROTOCOL = list(ENCODE_ENC1), OPERATING_PROTOCOL = list(OPERATING_NTOS))
#define AUGMENT_NT_HIGHLEVEL list(SECURITY_PROTOCOL = list(SECURITY_NT2 , SECURITY_NT1), ENCODE_PROTOCOL = list(ENCODE_ENC2), OPERATING_PROTOCOL = list(OPERATING_NTOS))
#define AUGMENT_TG_LEVEL list(SECURITY_PROTOCOL = list(SECURITY_NTX , SECURITY_NT2 , SECURITY_TMSP), ENCODE_PROTOCOL = list(ENCODE_TENN), OPERATING_PROTOCOL = list(OPERATING_TGMF))
#define AUGMENT_SYNDICATE_LEVEL list(SECURITY_PROTOCOL = list(SECURITY_TOSP), ENCODE_PROTOCOL = list(ENCODE_CSEP , ENCODE_TENN), OPERATING_PROTOCOL = list(OPERATING_CSOF))
#define AUGMENT_ADMIN_LEVEL list(SECURITY_PROTOCOL = list(SECURITY_NTX , SECURITY_NT2 , SECURITY_NT1, SECURITY_TMSP, SECURITY_TOSP), ENCODE_PROTOCOL = list(ENCODE_ENC1, ENCODE_ENC2, ENCODE_CSEP, ENCODE_TENN), OPERATING_PROTOCOL = list(OPERATING_CSOF, OPERATING_TGMF, OPERATING_NTOS))

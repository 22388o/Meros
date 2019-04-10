#Util lib.
import ../../../lib/Util

#Hash lib.
import ../../../lib/Hash

#Merkle lib.
import ../../../Database/common/Merkle

#MinerWallet lib (for BLSSignature's toString).
import ../../../Wallet/MinerWallet

#BlockHeader object.
import ../../../Database/Merit/objects/BlockHeaderObj

#Common serialization functions.
import ../SerializeCommon

#Serialize a Block Header.
func serialize*(header: BlockHeader): string {.raises: [].} =
    result =
        header.nonce.toBinary().pad(INT_LEN) &
        header.last.toString() &
        header.aggregate.toString() &
        header.miners.toString() &
        header.time.toBinary().pad(INT_LEN) &
        header.proof.toBinary().pad(INT_LEN)

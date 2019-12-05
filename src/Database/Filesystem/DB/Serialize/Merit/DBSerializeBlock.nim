#Errors lib.
import ../../../../../lib/Errors

#Util lib.
import ../../../../../lib/Util

#MinerWallet lib.
import ../../../../../Wallet/MinerWallet

#Element libs.
import ../../../../Consensus/Elements/Elements

#Block lib.
import ../../../../Merit/Block

#Serialization libs.
import ../../../../../Network/Serialize/SerializeCommon
import ../../../../../Network/Serialize/Merit/SerializeBlockHeader

import ../../../../../Network/Serialize/Consensus/SerializeVerification
import ../../../../../Network/Serialize/Consensus/SerializeVerificationPacket
import ../../../../../Network/Serialize/Consensus/SerializeMeritRemoval

#Serialize a Block.
proc serialize*(
    blockArg: Block
): string {.forceCheck: [].} =
    result =
        blockArg.header.serialize() &
        blockArg.body.packets.len.toBinary(INT_LEN)

    for packet in blockArg.body.packets:
        result &= packet.serialize()

    result &= blockArg.body.elements.len.toBinary(INT_LEN)
    for elem in blockArg.body.elements:
        case elem:
            of MeritRemoval as _:
                result &= char(MERIT_REMOVAL_PREFIX)
            else:
                doAssert(false, "serialize(BlockBody) tried to serialize an unsupported Element.")
        result &= elem.serialize()

    result &= blockArg.body.aggregate.toString()

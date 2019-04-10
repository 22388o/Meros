#Errors lib.
import ../../lib/Errors

#Hash lib.
import ../../lib/Hash

#Merkle lib.
import ../common/Merkle

#MinerWallet lib.
import ../../Wallet/MinerWallet

#Verifier object.
import objects/VerifierObj
export VerifierObj

#Verification lib.
import Verification

#Finals lib.
import finals

#Calculate the Merkle.
proc calculateMerkle*(verifier: Verifier, nonce: Natural): string {.raises: [ValueError].} =
    #Calculate how many leaves we're trimming.
    var toTrim: int = verifier.height - (nonce + 1)
    if toTrim < 0:
        raise newException(ValueError, "Nonce is out of bounds.")

    #Return the hash of this Verifier's trimmed Merkle.
    result = verifier.merkle.trim(toTrim).hash.toString()

#Calculate the aggregate signature.
proc calculateSig*(verifs: seq[MemoryVerification]): BLSSignature {.raises: [BLSError].} =
    #If there's no verifications...
    if verifs.len == 0:
        return nil

    #Declare a seq for the Signatures.
    var sigs: seq[BLSSignature]
    #Put every signature in the seq.
    for verif in verifs:
        sigs.add(verif.signature)
    #Set the aggregate.
    result = sigs.aggregate()

#Verify the aggregate signature.
proc verify*(verifs: seq[Verification], sig: BLSSignature): bool {.raises: [BLSError].} =
    #If there's no verifications...
    if verifs.len == 0:
        return sig == nil

    #Create the Aggregation Infos.
    var agInfos: seq[BLSAggregationInfo] = @[]
    try:
        for verif in verifs:
            agInfos.add(newBLSAggregationInfo(verif.verifier, verif.hash.toString()))
    except:
        raise newException(BLSError, "Couldn't allocate space for the AggregationInfo.")

    #Add the aggregated Aggregation Infos to the signature.
    sig.setAggregationInfo(agInfos.aggregate())

    #Verify the signature.
    result = sig.verify()

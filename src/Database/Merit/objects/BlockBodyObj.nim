#Errors lib.
import ../../../lib/Errors

#BlockBody object.
type BlockBody* = object
    #List of Transactions which have new/updated Verification Packets.
    transactions*: seq[Hash[384]]
    #Elements included in this Block.
    elements*: seq[Element]
    #Aggregate signature.
    aggregate: BLSSignature

#Constructor.
func newBlockBodyObj*(
    transactions: seq[Hash[384]],
    elements: seq[Element],
    aggregate: BLSSignature
): BlockBody {.inline, forceCheck: [].} =
    BlockBody(
        transactions: transactions,
        elements: elements,
        aggregate: aggregate
    )

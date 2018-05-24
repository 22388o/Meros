import ../lib/BN
import ../lib/time

import ./Block as BlockFile
import ./Difficulty as DifficultyFile

import lists

type Blockchain* = ref object of RootObj
    creation: BN
    genesis: string
    height: BN
    blocks: DoublyLinkedList[Block]
    difficulties: DoublyLinkedList[Difficulty]

proc createBlockchain*(genesis: string): Blockchain =
    result = Blockchain(
        creation: getTime(),
        genesis: genesis,
        height: newBN("0"),
        blocks: initDoublyLinkedList[Block](),
        difficulties: initDoublyLinkedList[Difficulty]()
    );

    result.difficulties.append(Difficulty(
        start: result.creation,
        endTime: result.creation + newBN("60"),
        difficulty: "88888888"
    ))
    result.blocks.append(createBlock(newBN("0"), "1", "0"))

proc addBlock*(blockchain: Blockchain, newBlock: Block) =
    if blockchain.height + newBN("1") != newBlock.nonce:
        raise newException(Exception, "Invalid nonce")

    verifyBlock(newBlock)

    while blockchain.difficulties.tail.value.endTime < newBlock.time:
        blockchain.difficulties.append(calculateNextDifficulty(blockchain.blocks, blockchain.difficulties))

    blockchain.difficulties.tail.value.verifyDifficulty(newBlock)

    inc(blockchain.height)
    blockchain.blocks.append(newBlock)

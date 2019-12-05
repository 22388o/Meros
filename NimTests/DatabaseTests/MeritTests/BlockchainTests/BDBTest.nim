#Blockchain DB Test.

#Util lib.
import ../../../../src/lib/Util

#Hash lib.
import ../../../../src/lib/Hash

#MinerWallet lib.
import ../../../../src/Wallet/MinerWallet

#Element libs.
import ../../../../src/Database/Consensus/Elements/Elements

#Difficulty, Block, Blockchain, and State libs.
import ../../../../src/Database/Merit/Difficulty
import ../../../../src/Database/Merit/Block
import ../../../../src/Database/Merit/Blockchain
import ../../../../src/Database/Merit/State

#Merit Testing lib.
import ../TestMerit

#Compare Merit lib.
import ../CompareMerit

#Tables lib.
import tables

#Random standard lib.
import random

proc test*() =
    #Seed random.
    randomize(int64(getTime()))

    var
        #Database.
        db: DB = newTestDatabase()
        #Starting Difficultty.
        startDifficulty: Hash[384] = "00AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".toHash(384)
        #Blockchain.
        blockchain: Blockchain = newBlockchain(
            db,
            "BLOCKCHAIN_TEST",
            30,
            startDifficulty
        )
        #State. This is needed for the Blockchain's nickname table.
        state: State = newState(
            db,
            10,
            1
        )

        #Transaction hash.
        hash: Hash[384]
        #Packets.
        packets: seq[VerificationPacket]
        #Elements.
        elements: seq[BlockElement]
        #Miners.
        miners: seq[MinerWallet]
        #Selected miner for the next Block.
        miner: int
        #Block.
        mining: Block

    #Iterate over 20 'rounds'.
    for _ in 1 .. 20:
        if state.holders.len != 0:
            #Randomize the Packets.
            packets = @[]
            for _ in 0 ..< rand(300):
                packets.add(newValidVerificationPacket(state.holders))

        #Randomize the Elements.

        #Decide if this is a nickname or new miner Block.
        if (miners.len == 0) or (rand(2) == 0):
            #New miner.
            miner = miners.len
            miners.add(newMinerWallet())

            #Create the Block with the new miner.
            mining = newBlankBlock(
                uint32(0),
                blockchain.tail.header.hash,
                uint16(rand(50000)),
                char(rand(255)) & char(rand(255)) & char(rand(255)) & char(rand(255)),
                miners[miner],
                packets,
                elements
            )
        else:
            #Grab a random miner.
            miner = rand(high(miners))

            #Create the Block with the existing miner.
            mining = newBlankBlock(
                uint32(0),
                blockchain.tail.header.hash,
                uint16(rand(50000)),
                char(rand(255)) & char(rand(255)) & char(rand(255)) & char(rand(255)),
                uint16(miner),
                miners[miner],
                packets,
                elements
            )

        #Mine it.
        while blockchain.difficulty.difficulty > mining.header.hash:
            miners[miner].hash(mining.header, mining.header.proof + 1)

        #Add it to the Blockchain and State.
        blockchain.processBlock(mining)
        state.processBlock(blockchain)

        #Commit the DB.
        db.commit(blockchain.height)

        #Compare the Blockchains.
        compare(blockchain, newBlockchain(
            db,
            "BLOCKCHAIN_TEST",
            30,
            startDifficulty
        ))

    echo "Finished the Database/Merit/Blockchain/DB Test."

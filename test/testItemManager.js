const ItemManager = artifacts.require("./ItemManager.sol");

contract("ItemManager", accounts => {
        it("Should be able to add an Item", async () => {
            const itemManagerInstance = await ItemManager.deployed()
            const itemName = "Test1"
            const itemPrice = 500

            const result = await itemManagerInstance.createItem(itemName, itemPrice, {from: accounts[0]})
            assert.equal(result.logs[0].args._itemIndex, 0, "This is not the first item")

            const item = await itemManagerInstance.items(0)
            assert.equal(item._identifier, itemName, "The name of the created item does not match")
            assert.equal(item._itemPrice, itemPrice, "The price of the created item does not match")

        })

    }
)

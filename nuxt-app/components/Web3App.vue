<template>
  <div class="App">
        <h1>Event Trigger</h1>
        <h2>Items</h2>
        <b-table striped hover :items="items" :fields="fields">
          <template #cell(buynow)="data">
            <b-button @click="buyItem(data.item._item, data.item._itemPrice)">Buy</b-button>
          </template>
        </b-table>
        <h2>Add Items</h2>
        Cost in Wei: <b-form-input type="text" name="cost" v-model="itemCost" ></b-form-input>
        Item Identifier: <b-form-input type="text" name="itemName" v-model="itemName" ></b-form-input>
        <b-button
          @click="handleNewItem"
        >Create new Item</b-button>
  </div>
</template>

<script>
import getWeb3 from "./getWeb3";
import ItemManager from "../../build/contracts/ItemManager.json"
import ItemContract from "../../build/contracts/Item.json"

export default {
    name: "Web3App",
    components: {},
    data() {
        return {
            items: [],
            fields: [
              {
                key: '_identifier',
                label: 'Identifier',
                sortable: true
              },
              {
                key: '_itemPrice',
                label: 'Price',
                sortable: true
              },
              {
                key: '_item',
                label: 'Address of Item',
                sortable: true
              },
              {
                key: '_state',
                label: 'Step in Supplychain',
                sortable: true
              },
              {
                key: "buynow",
                label: "Buy Now"
              }
            ],
            itemCost: "",
            itemName:"",
            loading: true,
            accounts: null,
            networkId: null,
            web3: null,
            LocalItemManager: null,
        }
    },
    computed: {
    },
    watch: {
        
    },
    methods: {
        async handleNewItem() {
            // Hopefully create new Item
            await this.LocalItemManager.methods.createItem(this.itemName, this.itemCost).send({from: this.accounts[0]})

            /// Set our inputs to "" 
            this.itemName = ""
            this.itemCost = ""
        },
        async getItems() {
          // Set our items to empty array to refresh
          this.items = []

          // Get amount of items in existence
          const lastIndex = await this.LocalItemManager.methods.itemIndex().call()

          // Get all items and push into local items array
          for (let i = 0; i < lastIndex; i++) {
            let itemObj = await this.LocalItemManager.methods.items(i).call()
            this.items.push(itemObj)
          }
        },
        async buyItem(address, value) {
          // Send buy transaction to Item
          const result = await this.web3.eth.sendTransaction({
            from: this.accounts[0],
            to: address,
            value: value,
          })
        },
        listenToPaymentEvent() {
          // Assing that to this for internal use
          let that = this
          this.LocalItemManager.events.SupplyChainStep().on("data", async function(evt) {
            /// Get Items because fired events means, that something happends
            await that.getItems()

            // Allert of change
            let itemObj = await that.LocalItemManager.methods.items(evt.returnValues._itemIndex).call()
            if (evt.returnValues._step === "0"){
              alert("Item was created. Pay " + that.itemCost + " to this address to buy it: " + evt.returnValues._itemAddress)
            } else if (evt.returnValues._step === "1") {
              alert("Item " + itemObj._identifier + " was payed. Deliver Now!")
            } else {
              alert("Item " + itemObj._identifier + " was delivered")
            }
          } )
        }
        
    },
    
    async mounted() {
      try {
        // Get network provider and web3 instance.
        this.web3 = await getWeb3()
        // Use web3 to get the user's accounts.
        this.accounts = await this.web3.eth.getAccounts()

        // Get the contract instances.
        this.networkId = await this.web3.eth.net.getId()

        this.LocalItemManager = new this.web3.eth.Contract(
          ItemManager.abi,
          ItemManager.networks[this.networkId] && ItemManager.networks[this.networkId].address,
        )
        this.ItemContract = new this.web3.eth.Contract(
          ItemContract.abi,
          ItemContract.networks[this.networkId] && ItemContract.networks[this.networkId].address,
        )
        
        // Register evt handler
        this.listenToPaymentEvent()

        // Get Items to show
        await this.getItems()
        this.loading = false
      } catch (error) {
        // Catch any errors for any of the above operations.
        console.error(
          `Failed to load web3, accounts, or contract. Check console for details.`,
        );
        console.error(error);
      }
    }
}
</script>

# About

## DLT/Blockchain Task

This is test task. The selected task from the three available is:

> *1. Create your own Cryptocurrency for a consortium of three participants.*

The following is also required:

> *Your solution should include all smart contracts you may need, all interfaces and services along with any logic for smart contract deployment, event retrieval etc. Unit tests should be present as should a mechanism to explore your blockchain solution. API specification should be done at the appropriate level as should any UI interface.*

Also, another requirement is to satisfy the following:

(a.)

> * i. Clearly define and build the proposed blockchain network

> * ii. Implement smart contracts for the tokens/assets/etc

> * iii. Implement smart contracts for the consortium management as needed

> * iv. In case of 1. above, write a sample dApp to show only the balance of each participant and transfer functions amongst them

----

## The Selected Blockchain Solution

The underling blockchain selected is Ethereum.

----

## Dependencies

All that you need is Docker and in order to build everything without problems, Ubuntu Linux.

* Ubuntu 16 or Ubuntu 18 recommanded
* Docker version 18.06.1-ce - https://www.docker.com/products/docker-engine

----

## Why Using Docker

This *docker* solution aims to help build a way to run the *Geth* client *in background* in such a way so that the boot process can be *monitored* easily by scripts in a **fast way** and as soon as the startup process ends those scripts will automatically trigger other events such as *mine* without losing any time. Once the docker container is up and running and mining blocks, tha bash console will be triggered to view logs or **gracefully kill** the Ethereum client.

![Screen01](screenshot-01.jpg)

The docker container will automatically (**1.**) Copy the genesis state file (genesis.json); (**2.**) initialise the genesis block after setting up static nodes and so on; (**3.**) Start by running the client with verification checkpoints at boot (ipc, rpc, etc); (**4.**) Connect to at least another peer; (**4.**) Start mining blocks automatically; (**5.**) Leave the user in bin bash to execute other commands or kill geth.

```
    +-------------------+      +-------------------+
    |                   +----->+                   |
    | 172.17.0.2 node01 |      | 172.17.0.3 node02 |
    |                   +<-----+                   |
    +---^---------------+      +------+----------^-+
    |   |                             |          |
    |   |                             |          |
    |   +-----+-------------------+   |          |
    |         |                   +<--+          |
    +-------->+ 172.17.0.3 node03 |              |
              |                   +--------------+
              +-------------------+
```

----

## Building Docker

First build the first image for the first node, then the second one then finally the third one with the following commands (make sure all other containers are stopped to avoid conflicts):

`docker build -t ubuntu-geth-node-stats01 --build-arg NAME=1 .`

`docker build -t ubuntu-geth-node-stats02 --build-arg NAME=2 .`

`docker build -t ubuntu-geth-node-stats03 --build-arg NAME=3 .`

----

## Running Docker

### Running Docker: Running the First Node

In order to get the first available IP (`172.17.0.2`) address for this node, make sure you run this first.

`docker run --rm -it --name node01 -h node01 ubuntu-geth-node-stats01`

### Running Docker: Running the Second Node

Run this after running the first one and after you see the node one showing `unlockDone` and you will get the correct ip (`172.17.0.3`).

`docker run --rm -it --name node02 -h node02 ubuntu-geth-node-stats02`

### Running Docker: Running the Third Node

Finally, run this last to after the second one to get the correct ip (172.17.0.4).

`docker run --rm -it --name node03 -h node03 ubuntu-geth-node-stats03`

----

## Details About Node Accounts Configuration

In order not to confuse the different ethereum addresses it is a good idea to use [vanity eth js](https://www.npmjs.com/package/vanity-eth) for every node in the order of the node names. For example, we could therefore have a vanity address that starts with `0` `x` **`01...`** for `node` **`01`** and another one that starts with `0` `x` **`02...`** for `node` **`02`** and so on.

!NOTE: The password is short and easy to remember but in real-life this should be replaced by a long password or replaced by **[Hardware Wallets](https://www.hardware-wallets.net/ethereum/)** or **[Secure Enclave](https://www.computerhope.com/jargon/s/secure-enclave.htm)**. In this experiment we will need to to use pwd: 123

----

## Details About Node IDs Configuration

To help easily debug the network and to understand what node is connected of course the `--identity` value parameter for `geth` is the best solution but if the user doesn't run geth with that parameter then it is hard to understand what node is connected to what so to make it simple the following nodes are sorted based on the final vanity id so that every node will start with something like `enode://` **`01...`** for `node` **`01`** and `enode://` **`02...`** for `node` **`02`** and so on.

----

## Details About Every Node Misc

----

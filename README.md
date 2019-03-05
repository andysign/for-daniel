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

## The Blockchain

The underling blockchain selected is Ethereum.

## Dependencies

* docker

## Why Using Docker

This *docker* solution aims to help build a way to run the *Geth* client *in background* in such a way so that the boot process can be *monitored* easily by scripts in a **fast way** and as soon as the startup process ends those scripts will automatically trigger other events such as *mine* without losing any time. Once the docker container is up and running and mining blocks, tha bash console will be triggered to view logs or **gracefully kill** the Ethereum client.

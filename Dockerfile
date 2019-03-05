# docker build -t ubuntu-geth-node-stats01 --build-arg NAME=1 .
# docker build -t ubuntu-geth-node-stats02 --build-arg NAME=2 .
# docker build -t ubuntu-geth-node-stats03 --build-arg NAME=3 .

FROM ubuntu:16.04

RUN apt-get --fix-missing update
RUN apt-get install -y sudo
RUN sudo apt-get install -y wget curl

RUN echo install_geth-1.8.23
RUN wget http://ppa.launchpad.net/ethereum/ethereum/ubuntu/pool/main/e/ethereum/geth_1.8.23+build17682+xenial_amd64.deb
RUN dpkg -i geth_1.8.23+build17682+xenial_amd64.deb
RUN rm geth_1.8.23+build17682+xenial_amd64.deb
RUN ln -s /usr/bin/geth /root/geth

RUN echo build_genesis_json_from_puppeth
ENV NETWORKID 1234567890
COPY genesis.json /root/

RUN echo build_initgeth_sh
RUN touch ~/initgeth.sh && chmod +x ~/initgeth.sh && \
echo '#''!''/bin/bash' >> ~/initgeth.sh && \
echo 'geth init ~/genesis.json' >> ~/initgeth.sh

# DEFAULT build-arg then NAME definition
ARG NAME=name01
ENV NAME=${NAME}

RUN echo build_accounts_sh
ENV PASSWORD 123
RUN [ $NAME -eq "1" ] && echo 6b256f8f0dfbe6a57d41a68d135eb3db348df035679f6c6c10d8b87f73cf59c0 > ~/privkey.txt || echo ""
RUN [ $NAME -eq "2" ] && echo 7b98417687d193e2176e967d4f49e3ca1da48d5c75d72602626e6447fed29899 > ~/privkey.txt || echo ""
RUN [ $NAME -eq "3" ] && echo d9f2eaa9794455a3d1c8adc7d5717f58db768dc8ae3430f4473b30b1f5fdaa24 > ~/privkey.txt || echo ""
RUN touch ~/accounts.sh && chmod +x ~/accounts.sh && \
echo '#''!''/bin/bash' >> ~/accounts.sh && \
echo 'echo $PASSWORD > ~/pwd.txt' >> ~/accounts.sh && \
echo 'geth --password ~/pwd.txt account import ~/privkey.txt' >> ~/accounts.sh && \
echo '#rm ~/privkey.txt' >> ~/accounts.sh

RUN echo build_nodekey_sh
RUN [ $NAME -eq "1" ] && echo d4c84815715e96ce2cd168292f5f4ac9936b7c9a87216e2d21e7fed8386e7f98 > ~/nodekey || echo ""
RUN [ $NAME -eq "2" ] && echo ae73adda58cc379cf5d0c6c772c8ca828c50b974b45d1d2057a38d58317baa64 > ~/nodekey || echo ""
RUN [ $NAME -eq "3" ] && echo 989fc61967c868f52de2e693bf7233b0afe62aeadaaa3479d1983734fe31c912 > ~/nodekey || echo ""
RUN touch ~/nodekey.sh && chmod +x ~/nodekey.sh && \
echo 'cp nodekey ~/.ethereum/geth/' >> ~/nodekey.sh && \
echo '#rm nodekey' >> ~/nodekey.sh && \
echo 'echo nodekey done' >> ~/nodekey.sh

RUN echo build_staticnodes_sh
RUN touch ~/staticnodes.sh && chmod +x ~/staticnodes.sh && \
echo '#''!''/bin/bash' >> ~/staticnodes.sh && \
echo 'mkdir -p ~/.ethereum && touch ~/.ethereum/static-nodes.json' >> ~/staticnodes.sh && \
echo 'echo "[" >> ~/.ethereum/static-nodes.json' >> ~/staticnodes.sh && \
echo 'echo "\"enode://010516a6e3acd95b9cf69c39d1d799d3e9fb8bef76e4c53bc1b92753a73b03e2e1222119365508dbb2faf18b365d2d42c86a4d748b6a8a7d1fa11592afb55ac5@172.17.0.2:30303\"," >> ~/.ethereum/static-nodes.json' >> ~/staticnodes.sh && \
echo 'echo "\"enode://021e339379c1115da274bbd80f8014789c10682aa8b9e97a5a50d8c4127423fb628c8ab5e6bbc9d8e0ffbf1c7204d95f955ef17dcd06237eb5118820b8045cd0@172.17.0.3:30303\"," >> ~/.ethereum/static-nodes.json' >> ~/staticnodes.sh && \
echo 'echo "\"enode://03a46d5f0b7a5de1c7b2d4233693dbf5991d949ff789fb108081f57d796988f7788e23100f33ed82b1360ffa975c989aa7e76a4bebcc8aa8e427893ce43dd1f6@172.17.0.4:30303\""  >> ~/.ethereum/static-nodes.json' >> ~/staticnodes.sh && \
echo 'echo "]" >> ~/.ethereum/static-nodes.json' >> ~/staticnodes.sh && \
echo 'echo static-nodes done' >> ~/staticnodes.sh

RUN echo build_startgeth_sh
RUN touch ~/startgeth.sh && chmod +x ~/startgeth.sh && \
echo '#''!''/bin/bash' >> ~/startgeth.sh && \
echo 'nohup geth --networkid 1234567890 --identity $(hostname -I) --syncmode "full" --unlock 0 --password ~/pwd.txt --targetgaslimit 8000000 --maxpeers 2 --rpc --rpcaddr 0.0.0.0 --rpcport 8546 --rpccorsdomain "*" > ~/log 2> ~/log &' >> ~/startgeth.sh && \
echo 'echo startgeth done' >> ~/startgeth.sh

RUN echo build_watchstartup_sh
RUN touch ~/watchstartup.sh && chmod +x ~/watchstartup.sh && \
echo '#''!''/bin/bash' >> ~/watchstartup.sh && \
echo 'while [[ $(geth --exec "personal.listWallets[0].status" attach) != '\''"Unlocked"'\'' ]]; do sleep 0.1; done && echo unlockDone' >> ~/watchstartup.sh

RUN echo build_mine_sh
RUN touch ~/mine.sh && chmod +x ~/mine.sh && \
echo '#''!''/bin/bash' >> ~/mine.sh && \
echo 'echo mining' >> ~/mine.sh && \
echo 'geth --exec "admin.sleepBlocks('$NAME'-1);miner.start();admin.sleepBlocks(1000);miner.stop();" attach' >> ~/mine.sh && \
echo 'while (( $(geth --exec "eth.blockNumber" attach) <= 1000 )); do sleep 0.1; done && echo mine1BlockDone' >> ~/mine.sh

WORKDIR /root/

CMD ./initgeth.sh && ./accounts.sh && ./nodekey.sh && ./staticnodes.sh && ./startgeth.sh && ./watchstartup.sh && ./mine.sh && bash

# CMD bash

# docker run --rm -it --name node01 -h node01 ubuntu-geth-node-stats01 bash
# docker run --rm -it --name node02 -h node02 ubuntu-geth-node-stats02 bash
# docker run --rm -it --name node03 -h node03 ubuntu-geth-node-stats03 bash
# sudo rm -r .bash_history #optional b4 run

from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3


DECIMALS = 8
STARTING_PRICE = 200000000000
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork-dev", "mainnet-fork"]


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def get_publish():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return False
    else:
        return True


def get_address():
    # desplegamos un mock si no hay ninguno ya desplegado
    print(f"Deploying on network: {network.show_active()}")
    print("Deploying mock...")
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(MockV3Aggregator) <= 0:
            MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})
            print("Mock Deployed!")
        else:
            print("Mock already exists")
        return MockV3Aggregator[-1].address
    else:
        return config["networks"][network.show_active()]["eth_usd_price_feed"]
        print("using real mock")

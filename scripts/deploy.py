from brownie import FundMe
from scripts.helpful_scripts import (
    get_account,
    get_address,
    get_publish,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


def deploy_fund_me():
    account = get_account()
    # pass the price feed address to our fundme contract

    # if we are on persistent network like rinkeby, use the associated addres
    # otherwise, deploy mocks
    address = get_address()
    publish = get_publish()  # boolean

    fund_me = FundMe.deploy(address, {"from": account}, publish_source=publish)
    print(f"contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()

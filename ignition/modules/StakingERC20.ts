import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";



const StakingERC20Module = buildModule("StakingERC20Module", (m) => {

    const tokenAddress = "0x095bD4e1C40098214e20a714B1AADA08d44f1113";

    const stakingERC20 = m.contract("StakingERC20", [tokenAddress]);

    return { stakingERC20 };
});

export default StakingERC20Module;
pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Metadata.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract TransferrableVesting is ERC721Metadata, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Vest {
        uint256 amount;
        uint256 vestPeriodInSeconds;
        uint256 creationTimestamp;
        uint256 withdrawnAmount;
    }
    Vest[] public vestList;

    IERC20 public token;
    string internal _contractURI;

    constructor(address _token) public ERC721Metadata("Vested MPH", "veMPH") {
        token = IERC20(_token);
    }

    function vest(
        address to,
        uint256 amount,
        uint256 vestPeriodInSeconds
    ) external returns (uint256 vestIdx) {
        require(vestPeriodInSeconds > 0, "Vesting: vestPeriodInSeconds == 0");

        // transfer `amount` tokens from `msg.sender`
        token.safeTransferFrom(msg.sender, address(this), amount);

        // create vest object
        vestIdx = vestList.length; // 0-indexed
        vestList.push(
            Vest({
                amount: amount,
                vestPeriodInSeconds: vestPeriodInSeconds,
                creationTimestamp: now,
                withdrawnAmount: 0
            })
        );

        // mint NFT
        _safeMint(to, vestIdx);
    }

    function withdrawVested(address account, uint256 vestIdx)
        external
        returns (uint256 withdrawnAmount)
    {
        // compute withdrawable amount
        withdrawnAmount = _getVestWithdrawableAmount(account, vestIdx);
        if (withdrawnAmount == 0) {
            return 0;
        }

        // update vest object
        uint256 recordedWithdrawnAmount =
            vestList[vestIdx].withdrawnAmount;
        vestList[vestIdx]
            .withdrawnAmount = recordedWithdrawnAmount.add(withdrawnAmount);

        // transfer tokens to vest recipient
        token.safeTransfer(account, withdrawnAmount);
    }

    function getVestWithdrawableAmount(address account, uint256 vestIdx)
        external
        view
        returns (uint256)
    {
        return _getVestWithdrawableAmount(account, vestIdx);
    }

    function _getVestWithdrawableAmount(address account, uint256 vestIdx)
        internal
        view
        returns (uint256)
    {
        if (ownerOf(vestIdx) != account) {
            return 0;
        }

        // read vest data
        Vest storage vest = vestList[vestIdx];
        uint256 vestFullAmount = vest.amount;
        uint256 vestCreationTimestamp = vest.creationTimestamp;
        uint256 vestPeriodInSeconds = vest.vestPeriodInSeconds;

        // compute vested amount
        uint256 vestedAmount;
        if (now >= vestCreationTimestamp.add(vestPeriodInSeconds)) {
            // vest period has passed, fully withdrawable
            vestedAmount = vestFullAmount;
        } else {
            // vest period has not passed, linearly unlock
            vestedAmount = vestFullAmount
                .mul(now.sub(vestCreationTimestamp))
                .div(vestPeriodInSeconds);
        }

        // deduct already withdrawn amount and return
        return vestedAmount.sub(vest.withdrawnAmount);
    }

    // NFT metadata

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function setContractURI(string calldata newURI) external onlyOwner {
        _contractURI = newURI;
    }

    function setTokenURI(uint256 tokenId, string calldata newURI)
        external
        onlyOwner
    {
        _setTokenURI(tokenId, newURI);
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _setBaseURI(newURI);
    }
}

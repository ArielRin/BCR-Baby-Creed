/*
BabyCreed

BabyCreed (BCR) is a project created by the CREED team that generates income through
real-world assets like stocks, mutual funds, and banking interest.
Website: https://creed-one.com/baby-creed
Whitepaper: https://bit.ly/BabyCreedPaper
Telegram: https://t.me/BabyCreedToken
Twitter X: https://twitter.com/creedfinance1
Github Contracts: https://github.com/ArielRin/BCR-Baby-Creed

Tokenomics
Supply: 1.5 Trillion Tokens
5% on Buys and Sells (2% LP 3% Utility)
MaxTX: 100,000,000
Swap and liquify at 100 not 300 now





Deploy Constructors required
add destroy tokens with trueburn
Arg [0] : name_ (string): Baby CREED
Arg [1] : symbol_ (string): BCR
Arg [2] : totalSupply_ (uint256): 1500000000000
Arg [3] : decimals_ (uint8): 18
Arg [4] : addr_ (address[5]): ***SEEBOLOW FOR CORRECT STRING*******
Arg [5] : value_ (uint256[6]): ["0","0","3","2","0","0"]

// STRING ["0x87e8B18Fda7A61db217E1C279135566A90862479","0x7699c7f12c321eE818dF5066178A3E15EB27c498","0x5a501DD7BF174cd1aE7a4DE5260Ec5717CbC7B19","0x10ED43C718714eb63d5aA57B78B54704E256024E","0x3A9D1bA4cA2713CF3226d62218CB77eF0028fc55"]


*/


// SPDX-License-Identifier: MIT
pragma solidity 0.8.12; // Ensure this matches your compiler version

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/Address.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";



contract BabyCreed is ERC20, Ownable {
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint8 private _decimals;

    address payable public InvestmentStocksAddress;
    address payable public MutualFundsFeeAddress;
    address payable public TreasuryFeeAddress;
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal = 0;

    uint256 public _FeeReflections;
    uint256 private _previousReflectionFee;

    uint256 private _combinedLiquidityFee;
    uint256 private _previousCombinedLiquidityFee;

    uint256 public _FeeLiquidityPool;
    uint256 private _previousLiquidityPoolFee;

    uint256 public _FeeBuyback;
    uint256 private _previousBuybackFee;

    uint256 public _FeeInvestmentStocks;
    uint256 private _previousMarketingFee;

    uint256 public _FeeMutualFunds;
    uint256 private _previousDeveloperFee;

    uint256 public _FeeTreasuryFee;
    uint256 private _previousTreasuryFee;

    uint256 public _maxTxAmount;
    uint256 private _previousMaxTxAmount;
    uint256 private minimumTokensBeforeSwap;
    uint256 private buyBackUpperLimit;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public buyBackEnabled = true;

    event RewardLiquidityProviders(uint256 tokenAmount);
    event BuyBackEnabledUpdated(bool enabled);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint8 decimals_,
        address[5] memory addr_,
        uint256[6] memory value_
    ) payable ERC20(name_, symbol_) {
        _decimals = decimals_;
        _tTotal = totalSupply_ * 10**decimals_;
        _rTotal = (MAX - (MAX % _tTotal));

        _FeeReflections = value_[5];
        _previousReflectionFee = _FeeReflections;

        _FeeLiquidityPool = value_[3];
        _previousLiquidityPoolFee = _FeeLiquidityPool;

        _FeeBuyback = value_[4];
        _previousBuybackFee = _FeeBuyback;

        _FeeInvestmentStocks = value_[0];
        _previousMarketingFee = _FeeInvestmentStocks;
        _FeeMutualFunds = value_[1];
        _previousDeveloperFee = _FeeMutualFunds;
        _FeeTreasuryFee = value_[2];
        _previousTreasuryFee = _FeeTreasuryFee;

        _combinedLiquidityFee =
            _FeeInvestmentStocks +
            _FeeMutualFunds +
            _FeeTreasuryFee +
            _FeeLiquidityPool +
            _FeeBuyback;
        _previousCombinedLiquidityFee = _combinedLiquidityFee;

        InvestmentStocksAddress = payable(addr_[0]);
        MutualFundsFeeAddress = payable(addr_[1]);
        TreasuryFeeAddress = payable(addr_[2]);

        _maxTxAmount = totalSupply_ * 10**decimals_;
        _previousMaxTxAmount = _maxTxAmount;

        minimumTokensBeforeSwap = ((totalSupply_ * 10**decimals_) / 10000) * 2;
        buyBackUpperLimit = 100000 * 10**18;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addr_[3]);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[InvestmentStocksAddress] = true;
        _isExcludedFromFee[MutualFundsFeeAddress] = true;
        _isExcludedFromFee[TreasuryFeeAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _mintStart(_msgSender(), _rTotal, _tTotal);
        payable(addr_[4]).transfer(getBalance());
    }

    receive() external payable {}

    function getBalance() private view returns (uint256) {
        return address(this).balance;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _tTotal;
    }

    /**
     * @dev Allows anyone to destroy their tokens, reducing the total supply.
     * @param amount The amount of tokens to be destroyed.
     */
    function DestroyTokens(uint256 amount) public {
        require(amount > 0, "Destroy amount should be greater than zero");
        uint256 accountBalance = balanceOf(msg.sender);
        require(accountBalance >= amount, "Destroy amount exceeds balance");

        // Reduce the total supply
        _tTotal -= amount;

        // Adjust the reflected balance
        _rOwned[msg.sender] -= amount * _getRate();

        // If the account is excluded from reward, reduce its token balance
        if (_isExcluded[msg.sender]) {
            _tOwned[msg.sender] -= amount;
        }

        // Emit the transfer event to the zero address
        emit Transfer(msg.sender, address(0), amount);
    }

    function balanceOf(address sender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (_isExcluded[sender]) {
            return _tOwned[sender];
        }
        return tokenFromReflection(_rOwned[sender]);
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function buyBackUpperLimitAmount() public view returns (uint256) {
        return buyBackUpperLimit;
    }

    function setLiquidityPoolFee(uint256 liquidityPoolFee_) external onlyOwner {
        _FeeLiquidityPool = liquidityPoolFee_;
        _combinedLiquidityFee =
            _FeeBuyback +
            _FeeLiquidityPool +
            _FeeInvestmentStocks +
            _FeeMutualFunds +
            _FeeTreasuryFee;
    }

    function setBuybackFee(uint256 buybackFee_) external onlyOwner {
        _FeeBuyback = buybackFee_;
        _combinedLiquidityFee =
            _FeeBuyback +
            _FeeLiquidityPool +
            _FeeInvestmentStocks +
            _FeeMutualFunds +
            _FeeTreasuryFee;
    }

    function setFeeInvestmentStocks(uint256 marketingFee_) external onlyOwner {
        _FeeInvestmentStocks = marketingFee_;
        _combinedLiquidityFee =
            _FeeBuyback +
            _FeeLiquidityPool +
            _FeeInvestmentStocks +
            _FeeMutualFunds +
            _FeeTreasuryFee;
    }

    function setFeeMutualFunds(uint256 developerFee_) external onlyOwner {
        _FeeMutualFunds = developerFee_;
        _combinedLiquidityFee =
            _FeeBuyback +
            _FeeLiquidityPool +
            _FeeInvestmentStocks +
            _FeeMutualFunds +
            _FeeTreasuryFee;
    }

    function setTreasuryFee(uint256 TreasuryFee_) external onlyOwner {
        _FeeTreasuryFee = TreasuryFee_;
        _combinedLiquidityFee =
            _FeeBuyback +
            _FeeLiquidityPool +
            _FeeInvestmentStocks +
            _FeeMutualFunds +
            _FeeTreasuryFee;
    }

    function setInvestmentStocksAddress(address _FeeInvestmentStocksAddress) external onlyOwner {
        InvestmentStocksAddress = payable(_FeeInvestmentStocksAddress);
    }

    function setMutualFundsFeeAddress(address _MutualFundsFeeAddress) external onlyOwner {
        MutualFundsFeeAddress = payable(_MutualFundsFeeAddress);
    }

    function setTreasuryFeeAddress(address _TreasuryFeeAddress) external onlyOwner {
        TreasuryFeeAddress = payable(_TreasuryFeeAddress);
    }

    function setNumTokensSellToAddToLiquidity(uint256 _minimumTokensBeforeSwap)
        external
        onlyOwner
    {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner {
        buyBackUpperLimit = buyBackLimit;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setBuyBackEnabled(bool _enabled) public onlyOwner {
        buyBackEnabled = _enabled;
        emit BuyBackEnabledUpdated(_enabled);
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        _maxTxAmount = maxTxAmount;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFeesRedistributed() public view returns (uint256) {
        return _tFeeTotal;
    }

    function setReflectionFee(uint256 newReflectionFee) public onlyOwner {
        _FeeReflections = newReflectionFee;
    }

    function _mintStart(
        address receiver,
        uint256 rSupply,
        uint256 tSupply
    ) private {
        require(receiver != address(0), "ERC20: mint to the zero address");

        _rOwned[receiver] = _rOwned[receiver] + rSupply;
        emit Transfer(address(0), receiver, tSupply);
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , ) = _getTransferValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , ) = _getTransferValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , ) = _getTransferValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeAccountFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccountinReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 senderBalance = balanceOf(sender);
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (sender != owner() && recipient != owner()) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;

        if (
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            recipient == uniswapV2Pair
        ) {
            if (overMinimumTokenBalance) {
                contractTokenBalance = minimumTokensBeforeSwap;
                swapTokens(contractTokenBalance);
            }
            uint256 balance = address(this).balance;
            if (buyBackEnabled && balance > uint256(1 * 10**18)) {
                if (balance > buyBackUpperLimit) balance = buyBackUpperLimit;

                buyBackTokens(balance - 100);
            }
        }

        bool takeFee = true;

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 value,
        bool takeFee
    ) private {
        if (!takeFee) {
            removeAllFee();
        }

        _transferStandard(from, to, value);

        if (!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 tTransferAmount,
            uint256 currentRate
        ) = _getTransferValues(tAmount);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender] - tAmount;
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        }

        _reflectFee(tAmount, currentRate);
        feeTransfer(
            sender,
            tAmount,
            currentRate,
            _combinedLiquidityFee,
            address(this)
        );

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getTransferValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 taxValue = _getCompleteTaxValue(tAmount);
        uint256 tTransferAmount = tAmount - taxValue;
        uint256 currentRate = _getRate();
        uint256 rTransferAmount = tTransferAmount * currentRate;
        uint256 rAmount = tAmount * currentRate;
        return (rAmount, rTransferAmount, tTransferAmount, currentRate);
    }

    function _getCompleteTaxValue(uint256 amount)
        private
        view
        returns (uint256)
    {
        uint256 allTaxes = _combinedLiquidityFee + _FeeReflections;
        uint256 taxValue = (amount * allTaxes) / 100;
        return taxValue;
    }

    function _reflectFee(uint256 tAmount, uint256 currentRate) private {
        uint256 tFee = (tAmount * _FeeReflections) / 100;
        uint256 rFee = tFee * currentRate;

        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function feeTransfer(
        address sender,
        uint256 tAmount,
        uint256 currentRate,
        uint256 fee,
        address receiver
    ) private {
        uint256 tFee = (tAmount * fee) / 100;
        if (tFee > 0) {
            uint256 rFee = tFee * currentRate;
            _rOwned[receiver] = _rOwned[receiver] + rFee;
            emit Transfer(sender, receiver, tFee);
        }
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) {
                return (_rTotal, _tTotal);
            }
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }

        if (rSupply < _rTotal / _tTotal) {
            return (_rTotal, _tTotal);
        }

        return (rSupply, tSupply);
    }

    function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
        uint256 initialBalance = address(this).balance;
        uint256 lpTokenBalance = (contractTokenBalance * _FeeLiquidityPool) /
            _combinedLiquidityFee;

        uint256 liquidityHalf = lpTokenBalance / 2;
        uint256 otherLiquidityHalf = lpTokenBalance - liquidityHalf;
        swapTokensForEth(contractTokenBalance - otherLiquidityHalf);

        uint256 transferredBalance = address(this).balance - initialBalance;

        transferToAddressETH(
            InvestmentStocksAddress,
            ((transferredBalance) * (_FeeInvestmentStocks * 10)) /
                (_combinedLiquidityFee * 10 - ((_FeeLiquidityPool * 10) / 2))
        );
        transferToAddressETH(
            MutualFundsFeeAddress,
            ((transferredBalance) * (_FeeMutualFunds * 10)) /
                (_combinedLiquidityFee * 10 - ((_FeeLiquidityPool * 10) / 2))
        );
        transferToAddressETH(
            TreasuryFeeAddress,
            ((transferredBalance) * (_FeeTreasuryFee * 10)) /
                (_combinedLiquidityFee * 10 - ((_FeeLiquidityPool * 10) / 2))
        );

        uint256 liquidityBalance = (transferredBalance *
            ((_FeeLiquidityPool * 10) / 2)) /
            ((_combinedLiquidityFee * 10) - ((_FeeLiquidityPool * 10) / 2));

        addLiquidity(otherLiquidityHalf, liquidityBalance);

        emit SwapAndLiquify(
            liquidityHalf,
            liquidityBalance,
            otherLiquidityHalf
        );
    }

    function buyBackTokens(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapETHForTokens(amount);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapETHForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp + 100
        );

        emit SwapETHForTokens(amount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function removeAllFee() private {
        if (_combinedLiquidityFee == 0 && _FeeReflections == 0) return;

        _previousCombinedLiquidityFee = _combinedLiquidityFee;
        _previousLiquidityPoolFee = _FeeLiquidityPool;
        _previousBuybackFee = _FeeBuyback;
        _previousReflectionFee = _FeeReflections;
        _previousMarketingFee = _FeeInvestmentStocks;
        _previousDeveloperFee = _FeeMutualFunds;
        _previousTreasuryFee = _FeeTreasuryFee;

        _combinedLiquidityFee = 0;
        _FeeLiquidityPool = 0;
        _FeeBuyback = 0;
        _FeeReflections = 0;
        _FeeInvestmentStocks = 0;
        _FeeMutualFunds = 0;
        _FeeTreasuryFee = 0;
    }

    function restoreAllFee() private {
        _combinedLiquidityFee = _previousCombinedLiquidityFee;
        _FeeLiquidityPool = _previousLiquidityPoolFee;
        _FeeBuyback = _previousBuybackFee;
        _FeeReflections = _previousReflectionFee;
        _FeeInvestmentStocks = _previousMarketingFee;
        _FeeMutualFunds = _previousDeveloperFee;
        _FeeTreasuryFee = _previousTreasuryFee;
    }

    function presale(bool _presale) external onlyOwner {
        if (_presale) {
            setSwapAndLiquifyEnabled(false);
            removeAllFee();
            _previousMaxTxAmount = _maxTxAmount;
            _maxTxAmount = totalSupply();
        } else {
            setSwapAndLiquifyEnabled(true);
            restoreAllFee();
            _maxTxAmount = _previousMaxTxAmount;
        }
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }
}

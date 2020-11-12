// ----------------------------------------------------------------------------
//          'GDAO' TOKEN CONTRACT
//              Symbol      | GDAO 
//              Name        | Governor DAO 
//              Supply      | 3 million
//              Decimals    | 18
// ----------------------------------------------------------------------------

pragma solidity 0.7.0;

// ----------------------------------------------------------------------------
//          CONTRACT | OWNED.SOL
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

// ----------------------------------------------------------------------------
//          LIBRARY | SAFEMATH.SOL
// ----------------------------------------------------------------------------
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

// ----------------------------------------------------------------------------
//          LIBRARY | ERC20Contract.SOL
// ----------------------------------------------------------------------------
 
// SPDX-License-Identifier: MIT
/* import "../../GSN/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol"; */

/*
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.

 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// ----------------------------------------------------------------------------
//          ERC20 | ADDS symbol, name, decimals and assisted token transfers
// ----------------------------------------------------------------------------
contract Token is ERC20Interface, Owned {
    using SafeMath for uint256;
    string public symbol = "GDAO";
    string public  name = "Governor DAO";
    uint256 public decimals = 18;
    uint256 private maxCapSupply = 3e6 * 10**(decimals); // 3 million
    uint256 _totalSupply = 0;
    address stakeFarmingContract;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    // ------------------------------------------------------------------------
    //          CONSTRUCTOR
    // ------------------------------------------------------------------------
    constructor() public {
        owner = msg.sender;
    }
    
    // ------------------------------------------------------------------------
    //          SET | STAKE_FARMING_CONTRACT
    // ------------------------------------------------------------------------
    function setStakeFarmingContract(address _address) public onlyOwner{
        stakeFarmingContract = _address;
    }
    
    // ------------------------------------------------------------------------
    //          TOKEN MINTING FUNCTIONS
    // ------------------------------------------------------------------------
    function mintTokens(uint256 _amount, address _beneficiary) public{
        require(msg.sender == owner || msg.sender == stakeFarmingContract);
        require(_totalSupply + _amount <= maxCapSupply, "exceeds max cap supply 3 million");
        _totalSupply += _amount;
        
        // mint _amount tokens and keep inside contract
        balances[_beneficiary] += _amount;
        emit Transfer(address(0),_beneficiary, _amount);
    }
    
    // ------------------------------------------------------------------------
    //          BURN FUNCTION
    // ------------------------------------------------------------------------
    function burnTokens(uint256 _amount) public {
        _burn(_amount, msg.sender);
    }

    // ------------------------------------------------------------------------
    //          BURN FUNCTION (FROM ACCOUNT)
    // ------------------------------------------------------------------------
    function _burn(uint256 _amount, address _account) internal {
        require(balances[_account] >= _amount, "insufficient account balance");
        _totalSupply = _totalSupply.sub(_amount);
        balances[address(_account)] = balances[address(_account)].sub(_amount);
        emit Transfer(address(_account), address(0), _amount);
    }
    
    /** ERC20Interface function's implementation **/
    
    // ------------------------------------------------------------------------
    //          QUERY | TOTAL SUPPLY
    // ------------------------------------------------------------------------
    function totalSupply() public override view returns (uint256){
       return _totalSupply; 
    }
    
    // ------------------------------------------------------------------------
    //         QUERY | TOKEN HOLDER BALANCE
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    //          TRANSFER | TOKEN BALANCE
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public override returns  (bool success) {
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
            
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    //          APPROVE | SPENDER TRANSFER FROM OWNER | OWNER APPROVES
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) public override returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    //          TRANSFERS | TOKENS
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){
        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens);
            
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    //          RETURNS | QTY TOKENS APPROVED FOR TRANSFER (FROM OWNER)
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
}

// ----------------------------------------------------------------------------
// -------------------- CONTRACT | GDAOSTAKINGFARM.SOL  -----------------------
// ----------------------------------------------------------------------------
contract GDAO_STAKE_FARM is Owned {
    
    using SafeMath for uint256;
    
    uint256 public yieldCollectionFee = 0.01 ether; // update
    uint256 public stakingPeriod = 30 days; // update
    uint256 public stakeClaimFee = 0.001 ether; //update
    uint256 public totalYield;
    uint256 public totalRewards;
    
    Token public gdao;
    
    struct Tokens{
        bool exists;
        uint256 rate;
    }
    
    mapping(address => Tokens) public tokens;
    address[] TokensAddresses;
    
    struct DepositedToken{
        bool    whitelisted;
        uint256 activeDeposit;
        uint256 totalDeposits;
        uint256 startTime;
        uint256 pendingGains;
        uint256 lastClaimedDate;
        uint256 totalGained;
        uint    rate;
        uint    period;
        //bool    running;
    }
    
    mapping(address => mapping(address => DepositedToken)) users;
    
    event TokenAdded(address tokenAddress, uint256 APY);
    event TokenRemoved(address tokenAddress);
    event FarmingRateChanged(address tokenAddress, uint256 newAPY);
    event YieldCollectionFeeChanged(uint256 yieldCollectionFee);
    event FarmingStarted(address _tokenAddress, uint256 _amount);
    event YieldCollected(address _tokenAddress, uint256 _yield);
    event AddedToExistingFarm(address _tokenAddress, uint256 tokens);
    
    event Staked(address staker, uint256 tokens);
    event AddedToExistingStake(uint256 tokens);
    event StakingRateChanged(uint256 newAPY);
    event TokensClaimed(address claimer, uint256 stakedTokens);
    event RewardClaimed(address claimer, uint256 reward);
    
    modifier isWhitelisted(address _account){
        require(users[_account][address(gdao)].whitelisted, "User is not whitelisted");
        _;
    }
    
    constructor(address _tokenAddress) public {
        gdao = Token(_tokenAddress);
        
        // add gdao token to ecosystem
        _addToken(_tokenAddress, 40); // 40 apy initially
    }
    
    // ------------------------------------------------------------------------
    // ################### FARMING EXTERNAL FUNCTIONS #########################
    // ------------------------------------------------------------------------
    
    // ------------------------------------------------------------------------
    //          ADD | DEPOSIT ASSETS TO FARM
    // ------------------------------------------------------------------------
    function FARM(address _tokenAddress, uint256 _amount) public{
        require(_tokenAddress != address(gdao), "Use staking instead"); 
        
        // add to farm
        _newDeposit(_tokenAddress, _amount);
        
        // transfer tokens from user to the contract balance
        ERC20Interface(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        
        emit FarmingStarted(_tokenAddress, _amount);
    }
    
    // ------------------------------------------------------------------------
    //          ADD | MORE DEPOSITS
    // ------------------------------------------------------------------------
    function addToFarm(address _tokenAddress, uint256 _amount) public{
        require(_tokenAddress != address(gdao), "Use staking instead");
        _addToExisting(_tokenAddress, _amount);
        
        // move the tokens from the caller to the contract address
        ERC20Interface(_tokenAddress).transferFrom(msg.sender,address(this), _amount);
        
        emit AddedToExistingFarm(_tokenAddress, _amount);
    }
    
    // ------------------------------------------------------------------------
    //          WITHDRAW | ACCUMULATED YIELD
    // ------------------------------------------------------------------------
    function YIELD(address _tokenAddress) public payable {
        require(msg.value >= yieldCollectionFee, "Should pay exact claim fee");
        require(pendingYield(_tokenAddress, msg.sender) > 0, "No pending yield");
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        
        // transfer fee to the owner
        owner.transfer(msg.value);
        // mint more tokens inside token contract
        gdao.mintTokens(pendingYield(_tokenAddress, msg.sender), msg.sender);
        
        emit YieldCollected(_tokenAddress, pendingYield(_tokenAddress, msg.sender));
        
        // Global stats update
        totalYield += pendingYield(_tokenAddress, msg.sender);
        
        // update the record
        users[msg.sender][_tokenAddress].totalGained += pendingYield(_tokenAddress, msg.sender);
        users[msg.sender][_tokenAddress].lastClaimedDate = now;
        users[msg.sender][_tokenAddress].pendingGains = 0;
    }
    
    // ------------------------------------------------------------------------
    //          WITHDRAW | ASSETS (UPDATE FARM) 
    // ------------------------------------------------------------------------
    function withdrawFarmedTokens(address _tokenAddress, uint256 _amount) public {
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        require(users[msg.sender][_tokenAddress].activeDeposit >= _amount, "Insufficient amount in farming");
        
        // withdraw the tokens and move from contract to the caller
        ERC20Interface(_tokenAddress).transfer(msg.sender, _amount);
        
        // update farming stats
            // check if we have any pending yield, add it to previousYield var
            users[msg.sender][_tokenAddress].pendingGains = pendingYield(_tokenAddress, msg.sender);
            // update amount 
            users[msg.sender][_tokenAddress].activeDeposit -= _amount;
            // update farming start time -- new farming will begin from this time onwards
            users[msg.sender][_tokenAddress].startTime = now;
            // reset last claimed figure as well -- new farming will begin from this time onwards
            users[msg.sender][_tokenAddress].lastClaimedDate = now;
            
            // update the farming rate
            users[msg.sender][_tokenAddress].rate = tokens[_tokenAddress].rate;
        
        emit TokensClaimed(msg.sender, _amount);
    }

    // ------------------------------------------------------------------------
    // ################## STAKING EXTERNAL FUNCTIONS ##########################
    // ------------------------------------------------------------------------
    
    // ------------------------------------------------------------------------
    //          START | STAKING
    // ------------------------------------------------------------------------
    function STAKE(uint256 _amount) public isWhitelisted(msg.sender) {
        // add new stake
        _newDeposit(address(gdao), _amount);
        
        // transfer tokens from user to the contract balance
        gdao.transferFrom(msg.sender, address(this), _amount);
        
        emit Staked(msg.sender, _amount);
        
    }
    
    // ------------------------------------------------------------------------
    //          ADD | MORE ASSETS
    // ------------------------------------------------------------------------
    function addToStake(uint256 _amount) public {
        require(now - users[msg.sender][address(gdao)].startTime < users[msg.sender][address(gdao)].period, "Current staking expired");
        _addToExisting(address(gdao), _amount);

        // move the tokens from the caller to the contract address
        gdao.transferFrom(msg.sender,address(this), _amount);
        
        emit AddedToExistingStake(_amount);
    }
    
    // ------------------------------------------------------------------------
    //          CLAIM | REWARD AND STAKED ASSETS
    // ------------------------------------------------------------------------
    function ClaimStakedTokens() external {
        //require(users[msg.sender][address(gdao)].running, "no running stake");
        require(users[msg.sender][address(gdao)].activeDeposit > 0, "No running stake");
        require(users[msg.sender][address(gdao)].startTime + users[msg.sender][address(gdao)].period < now, "Not claimable before staking period");
        
        // transfer staked tokens
        gdao.transfer(msg.sender, users[msg.sender][address(gdao)].activeDeposit);
        
        // check if we have any pending reward, add it to pendingGains var
        users[msg.sender][address(gdao)].pendingGains = pendingReward(msg.sender);
        // update amount 
        users[msg.sender][address(gdao)].activeDeposit = 0;
        
        emit TokensClaimed(msg.sender, users[msg.sender][address(gdao)].activeDeposit);
        
    }
    
    // ------------------------------------------------------------------------
    //          CLAIM | REWARD AND STAKED ASSETS
    // ------------------------------------------------------------------------
    function ClaimReward() external payable {
        require(msg.value >= stakeClaimFee, "Should pay exact claim fee");
        require(pendingReward(msg.sender) > 0, "Nothing pending to claim");
    
        // mint more tokens inside token contract
        gdao.mintTokens(pendingReward(msg.sender), msg.sender);
         
        emit RewardClaimed(msg.sender, pendingReward(msg.sender));
        
        // add claimed reward to global stats
        totalRewards += pendingReward(msg.sender);
        
        // add the reward to total claimed rewards
        users[msg.sender][address(gdao)].totalGained += pendingReward(msg.sender);
        // update lastClaim amount
        users[msg.sender][address(gdao)].lastClaimedDate = now;
        // reset previous rewards
        users[msg.sender][address(gdao)].pendingGains = 0;
        
        // transfer the claim fee to the owner
        owner.transfer(msg.value);
    }
    
    // ------------------------------------------------------------------------
    // ########################### FARMING QUERIES ############################
    // ------------------------------------------------------------------------
    
    // ------------------------------------------------------------------------
    //          QUERY | PENDING YIELD
    // ------------------------------------------------------------------------
    function pendingYield(address _tokenAddress, address _caller) public view returns(uint256 _pendingRewardWeis){
        uint256 _totalFarmingTime = now.sub(users[_caller][_tokenAddress].lastClaimedDate);
        
        uint256 _reward_token_second = ((users[_caller][_tokenAddress].rate).mul(10 ** 21)).div(365 days); // added extra 10^21
        
        uint256 yield = ((users[_caller][_tokenAddress].activeDeposit).mul(_totalFarmingTime.mul(_reward_token_second))).div(10 ** 23); // remove extra 10^21 // 10^2 are for 100 (%)
        
        return yield.add(users[_caller][_tokenAddress].pendingGains);
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | ACTIVE FARM (FOR USER)
    // ------------------------------------------------------------------------
    function activeFarmDeposit(address _tokenAddress, address _user) public view returns(uint256 _activeDeposit){
        return users[_user][_tokenAddress].activeDeposit;
    }

    // ------------------------------------------------------------------------
    //          QUERY | FARMING RATE
    // ------------------------------------------------------------------------
    function yourFarmingRate(address _tokenAddress, address _user) public view returns(uint256 _farmingRate){
        return users[_user][_tokenAddress].rate;
    }

    // ------------------------------------------------------------------------
    //          QUERY | TOTAL FARMING ASSETS
    // ------------------------------------------------------------------------
    function yourTotalFarmingTillToday(address _tokenAddress, address _user) public view returns(uint256 _totalFarming){
        return users[_user][_tokenAddress].totalDeposits;
    }

    // ------------------------------------------------------------------------
    //          QUERY | LAST FARM TIME
    // ------------------------------------------------------------------------
    function lastFarmedOn(address _tokenAddress, address _user) public view returns(uint256 _unixLastFarmedTime){
        return users[_user][_tokenAddress].startTime;
    }

    // ------------------------------------------------------------------------
    //          QUERY | TOTAL FARMING REWARDS
    // ------------------------------------------------------------------------
    function totalFarmingRewards(address _tokenAddress, address _user) public view returns(uint256 _totalEarned){
        return users[_user][_tokenAddress].totalGained;
    }

    // ------------------------------------------------------------------------
    // #################### FARMING ONLY-OWNER FUNCTIONS ######################
    // ------------------------------------------------------------------------
   
    // ------------------------------------------------------------------------
    //          ADD | TOKEN ASSET
    // ------------------------------------------------------------------------    
    function addToken(address _tokenAddress, uint256 _rate) public onlyOwner {
        _addToken(_tokenAddress, _rate);
    }
    
    // ------------------------------------------------------------------------
    //          REMOVE | UNSUPPORTED TOKEN
    // ------------------------------------------------------------------------  
    function removeToken(address _tokenAddress) public onlyOwner {
        
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        
        tokens[_tokenAddress].exists = false;
        
        emit TokenRemoved(_tokenAddress);
    }
    
    // ------------------------------------------------------------------------
    //          ALTER | FARMING RATE (PER TOKEN)
    // ------------------------------------------------------------------------  
    function changeFarmingRate(address _tokenAddress, uint256 _newFarmingRate) public onlyOwner {
        
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        
        tokens[_tokenAddress].rate = _newFarmingRate;
        
        emit FarmingRateChanged(_tokenAddress, _newFarmingRate);
    }

    // ------------------------------------------------------------------------
    //          ALTER | YIELD COLLECTION FEE (TAX)
    // ------------------------------------------------------------------------     
    function setYieldCollectionFee(uint256 _fee) public{
        yieldCollectionFee = _fee;
        emit YieldCollectionFeeChanged(_fee);
    }
    
    // -------------------------------------------------------------------------
    // ########################## STAKING QUERIES ##############################
    // -------------------------------------------------------------------------
    
    // ------------------------------------------------------------------------
    //          QUERY | REWARD (PENDING)
    // ------------------------------------------------------------------------
    function pendingReward(address _caller) public view returns(uint256 _pendingReward){
        uint256 _totalStakedTime = 0;
        uint256 expiryDate = (users[_caller][address(gdao)].period).add(users[_caller][address(gdao)].startTime);
        
        if(now < expiryDate)
            _totalStakedTime = now.sub(users[_caller][address(gdao)].lastClaimedDate);
        else{
            if(users[_caller][address(gdao)].lastClaimedDate >= expiryDate) // if claimed after expiryDate already
                _totalStakedTime = 0;
            else
                _totalStakedTime = expiryDate.sub(users[_caller][address(gdao)].lastClaimedDate);
        }
            
        uint256 _reward_token_second = ((users[_caller][address(gdao)].rate).mul(10 ** 21)).div(365 days); // added extra 10^21
        uint256 reward =  ((users[_caller][address(gdao)].activeDeposit).mul(_totalStakedTime.mul(_reward_token_second))).div(10 ** 23); // remove extra 10^21 // the two extra 10^2 is for 100 (%)
        return (reward.add(users[_caller][address(gdao)].pendingGains));
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | ACTIVE STAKE
    // ------------------------------------------------------------------------
    function yourActiveStake(address _user) public view returns(uint256 _activeStake){
        return users[_user][address(gdao)].activeDeposit;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | TOTAL STAKE
    // ------------------------------------------------------------------------
    function yourTotalStakesTillToday(address _user) public view returns(uint256 _totalStakes){
        return users[_user][address(gdao)].totalDeposits;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | LAST STAKE TIME
    // ------------------------------------------------------------------------
    function lastStakedOn(address _user) public view returns(uint256 _unixLastStakedTime){
        return users[_user][address(gdao)].startTime;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | WHITELIST (BOOLEAN)
    // ------------------------------------------------------------------------
    function isUserWhitelisted(address _user) public view returns(bool _result){
        return users[_user][address(gdao)].whitelisted;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | TOTAL REWARDS
    // ------------------------------------------------------------------------
    function totalStakeRewardsClaimedTillToday(address _user) public view returns(uint256 _totalEarned){
        return users[_user][address(gdao)].totalGained;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | STAKING RATE (MOST RECENT)
    // ------------------------------------------------------------------------
    function latestStakingRate() public view returns(uint256 APY){
        return tokens[address(gdao)].rate;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | STAKING RATE (INITIAL)
    // ------------------------------------------------------------------------
    function yourStakingRate(address _user) public view returns(uint256 _stakingPeriod){
        return users[_user][address(gdao)].rate;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | STAKING PERIOD (INITIAL)
    // ------------------------------------------------------------------------
    function yourStakingPeriod(address _user) public view returns(uint256 _stakingPeriod){
        return users[_user][address(gdao)].period;
    }
    
    // ------------------------------------------------------------------------
    //          QUERY | STAKING TIME REMAINING
    // ------------------------------------------------------------------------
    function stakingTimeLeft(address _user) public view returns(uint256 _secsLeft){
        uint256 left = 0; 
        uint256 expiryDate = (users[_user][address(gdao)].period).add(lastStakedOn(_user));
        
        if(now < expiryDate)
            left = expiryDate.sub(now);
            
        return left;
    }
    
    // -------------------------------------------------------------------------
    // #################### STAKING ONLY-OWNER FUNCTION ########################
    // -------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    //          ALTER | STAKING RATE
    // ------------------------------------------------------------------------  
    function changeStakingRate(uint256 _newStakingRate) public onlyOwner{
        
        tokens[address(gdao)].rate = _newStakingRate;
        
        emit StakingRateChanged(_newStakingRate);
    }
    
    // ------------------------------------------------------------------------
    //          ADD | ADDRESS TO WHITE LIST
    // ------------------------------------------------------------------------
    function whiteList(address _account) public onlyOwner{
       users[_account][address(gdao)].whitelisted = true;
    }
    
    // ------------------------------------------------------------------------
    //          ALTER | STAKING PERIOD
    // ------------------------------------------------------------------------
    function setStakingPeriod(uint256 _seconds) public onlyOwner{
       stakingPeriod = _seconds;
    }
    
    // ------------------------------------------------------------------------
    //          ALTER | STAKING CLAIM FEE (TAX IN WEI)
    // ------------------------------------------------------------------------
    function setClaimFee(uint256 _fee) public onlyOwner{
       stakeClaimFee = _fee;
    }

    // ------------------------------------------------------------------------    
    // ########################## COMMON UTILITIES ############################
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    //          ADD | NEW DEPOSIT | INTERNAL FUNCTION
    // ------------------------------------------------------------------------        
    function _newDeposit(address _tokenAddress, uint256 _amount) internal{
        require(users[msg.sender][_tokenAddress].activeDeposit ==  0, "Already running");
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        
        // add that token into the contract balance
        // check if we have any pending reward/yield, add it to pendingGains variable
        if(_tokenAddress == address(gdao)){
            users[msg.sender][_tokenAddress].pendingGains = pendingReward(msg.sender);
            users[msg.sender][_tokenAddress].period = stakingPeriod;
        }
        else
            users[msg.sender][_tokenAddress].pendingGains = pendingYield(_tokenAddress, msg.sender);
            
        users[msg.sender][_tokenAddress].activeDeposit = _amount;
        users[msg.sender][_tokenAddress].totalDeposits += _amount;
        users[msg.sender][_tokenAddress].startTime = now;
        users[msg.sender][_tokenAddress].lastClaimedDate = now;
        
        
        users[msg.sender][_tokenAddress].rate = tokens[_tokenAddress].rate;
    }

    // ------------------------------------------------------------------------
    //          ADD | MORE DEPOSIT | INTERNAL FUNCTION
    // ------------------------------------------------------------------------        
    function _addToExisting(address _tokenAddress, uint256 _amount) internal{
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        // require(users[msg.sender][_tokenAddress].running, "no running farming/stake");
        require(users[msg.sender][_tokenAddress].activeDeposit > 0, "No running farming/stake");
        // update farming stats
            // check if we have any pending reward/yield, add it to pendingGains variable
            if(_tokenAddress == address(gdao)){
                users[msg.sender][_tokenAddress].pendingGains = pendingReward(msg.sender);
                users[msg.sender][_tokenAddress].period = stakingPeriod;
            }
            else
                users[msg.sender][_tokenAddress].pendingGains = pendingYield(_tokenAddress, msg.sender);
            // update current deposited amount 
            users[msg.sender][_tokenAddress].activeDeposit += _amount;
            // update total deposits till today
            users[msg.sender][_tokenAddress].totalDeposits += _amount;
            // update new deposit start time -- new stake/farming will begin from this time onwards
            users[msg.sender][_tokenAddress].startTime = now;
            // reset last claimed figure as well -- new stake/farming will begin from this time onwards
            users[msg.sender][_tokenAddress].lastClaimedDate = now;
            
            users[msg.sender][_tokenAddress].rate = tokens[_tokenAddress].rate;
    }

    // ------------------------------------------------------------------------
    //          ADD | NEW TOKEN ASSET | INTERNAL FUNCTION
    // ------------------------------------------------------------------------     
    function _addToken(address _tokenAddress, uint256 _rate) internal{
        require(!tokens[_tokenAddress].exists, "Token already exists");
        
        tokens[_tokenAddress] = Tokens({
            exists: true,
            rate: _rate
        });
        
        TokensAddresses.push(_tokenAddress);
        emit TokenAdded(_tokenAddress, _rate);
    }
    
    
}
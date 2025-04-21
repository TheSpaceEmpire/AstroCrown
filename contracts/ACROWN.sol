// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AstroCrown ERC20 with Tax, Pause & Reentrancy Guard
/// @notice Centralized mint/burn controlled by NOVA-managed admin, with transfer tax to TaxWallet
contract ACROWN {
    // --- ERC20 Metadata ---
    string public constant name     = "AstroCrown";
    string public constant symbol   = "ACROWN";
    uint8  public constant decimals = 18;

    /// @dev 10**(18 + decimals) = 10**36 base units = 1 000 000 000 000 000 000 human‑readable tokens
    uint256 public constant totalSupply = 10**36;

    // --- Governance Addresses ---
    address public immutable admin;      // NOVA‑controlled treasury
    address public immutable taxWallet;  // Where tax is accumulated
    address public immutable aiWallet;   // Reserved for AI‑governance operations

    // --- Tax & Pause ---
    /// @dev taxPercent is in basis points (i.e. 167 => 1.67%)
    uint256 public constant taxPercent = 167;
    bool    public paused;

    // --- Balances & Allowances ---
    mapping(address => uint256)                   private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // --- Reentrancy Guard ---
    uint256 private _guard;

    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused();
    event Unpaused();

    // --- Modifiers ---
    modifier onlyAdmin() {
        require(msg.sender == admin, "ACROWN: Not authorized");
        _;
    }
    modifier whenNotPaused() {
        require(!paused, "ACROWN: Paused");
        _;
    }
    modifier whenPaused() {
        require(paused, "ACROWN: Not paused");
        _;
    }
    modifier nonReentrant() {
        require(_guard == 0, "ACROWN: Reentrant call");
        _guard = 1;
        _;
        _guard = 0;
    }

    /// @param _taxWallet Address to receive transfer taxes
    /// @param _aiWallet  Address reserved for AI‑governance operations
    constructor(address _taxWallet, address _aiWallet) {
        require(_taxWallet != address(0) && _aiWallet != address(0), "ACROWN: Zero address");
        admin      = msg.sender;
        taxWallet  = _taxWallet;
        aiWallet   = _aiWallet;

        // Mint entire supply to admin (central treasury)
        balances[admin] = totalSupply;
        emit Transfer(address(0), admin, totalSupply);
    }

    // --- ERC20 Standard Functions ---

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        whenNotPaused
        nonReentrant
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        whenNotPaused
        returns (bool)
    {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        public
        whenNotPaused
        nonReentrant
        returns (bool)
    {
        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ACROWN: Allowance exceeded");
        allowances[sender][msg.sender] = currentAllowance - amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    // --- Internal Transfer with Tax Logic ---

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0) && to != address(0), "ACROWN: Zero address");
        uint256 senderBalance = balances[from];
        require(senderBalance >= amount, "ACROWN: Insufficient balance");

        uint256 taxAmount = 0;
        // Tax applies to non‑exempt addresses
        if (from != admin && from != taxWallet && from != aiWallet) {
            taxAmount = (amount * taxPercent) / 10000;
            balances[taxWallet] += taxAmount;
            emit Transfer(from, taxWallet, taxAmount);
        }

        uint256 netAmount = amount - taxAmount;
        balances[from] = senderBalance - amount;
        balances[to]   += netAmount;
        emit Transfer(from, to, netAmount);
    }

    // --- Emergency Pause / Unpause ---

    function pause() public onlyAdmin whenNotPaused {
        paused = true;
        emit Paused();
    }

    function unpause() public onlyAdmin whenPaused {
        paused = false;
        emit Unpaused();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract GNaira is ERC20, AccessControl, Pausable {
    // Role constants
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    // Blacklist tracking
    mapping(address => bool) private _blacklist;

    // External approver wallet
    address public approver;

    // Struct for a mint or burn request
    struct Request {
        address target;
        uint256 amount;
        bool approved;
        bool executed;
        uint256 timestamp;
    }

    uint256 public requestIdCounter;
    mapping(uint256 => Request) public mintRequests;
    mapping(uint256 => Request) public burnRequests;

    // Events
    event MintRequested(uint256 requestId, address indexed to, uint256 amount);
    event BurnRequested(
        uint256 requestId,
        address indexed from,
        uint256 amount
    );
    event Approved(uint256 requestId);
    event Executed(uint256 requestId);
    event ApproverChanged(address indexed oldApprover, address indexed newApprover);

    // Modifier to restrict blacklisted accounts
    modifier notBlacklisted(address addr) {
        require(!_blacklist[addr], "Address is blacklisted");
        _;
    }

    constructor(address governor, address _approver) ERC20("G-Naira", "gNGN") {
        require(
            governor != address(0) && _approver != address(0),
            "Invalid address"
        );

        // Grant admin to deployer but not governor
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GOVERNOR_ROLE, governor);

        approver = _approver;
    }

    // ---------------- BLACKLIST ----------------
    function blacklist(address user) external onlyRole(GOVERNOR_ROLE) {
        require(user != address(0), "Invalid address");
        _blacklist[user] = true;
    }

    function removeFromBlacklist(
        address user
    ) external onlyRole(GOVERNOR_ROLE) {
        require(user != address(0), "Invalid address");
        _blacklist[user] = false;
    }

    function isBlacklisted(address user) external view returns (bool) {
        return _blacklist[user];
    }

    // ----------------- TOKEN HOOK -----------------
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override whenNotPaused notBlacklisted(from) notBlacklisted(to) {
        super._update(from, to, value);
    }

    // ------------- MINT FLOW ---------------
    function requestMint(
        address to,
        uint256 amount
    ) external onlyRole(GOVERNOR_ROLE) returns (uint256) {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than 0");
        
        requestIdCounter++;
        mintRequests[requestIdCounter] = Request({
            target: to,
            amount: amount,
            approved: false,
            executed: false,
            timestamp: block.timestamp
        });
        
        emit MintRequested(requestIdCounter, to, amount);
        return requestIdCounter;
    }

    function approveMint(uint256 id) external {
        require(msg.sender == approver, "Not approver");
        Request storage r = mintRequests[id];
        require(!r.approved, "Already approved");
        require(!r.executed, "Already executed");
        require(block.timestamp <= r.timestamp + 24 hours, "Request expired");

        r.approved = true;
        emit Approved(id);
    }

    function executeMint(uint256 id) external onlyRole(GOVERNOR_ROLE) {
        Request storage r = mintRequests[id];
        require(r.approved, "Not approved");
        require(!r.executed, "Already executed");
        require(block.timestamp <= r.timestamp + 48 hours, "Request expired");

        r.executed = true;
        _mint(r.target, r.amount);
        emit Executed(id);
    }

    // ------------- BURN FLOW ---------------
    function requestBurn(
        address from,
        uint256 amount
    ) external onlyRole(GOVERNOR_ROLE) returns (uint256) {
        require(from != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(from) >= amount, "Insufficient balance");
        
        requestIdCounter++;
        burnRequests[requestIdCounter] = Request({
            target: from,
            amount: amount,
            approved: false,
            executed: false,
            timestamp: block.timestamp
        });
        
        emit BurnRequested(requestIdCounter, from, amount);
        return requestIdCounter;
    }

    function approveBurn(uint256 id) external {
        require(msg.sender == approver, "Not approver");
        Request storage r = burnRequests[id];
        require(!r.approved, "Already approved");
        require(!r.executed, "Already executed");
        require(block.timestamp <= r.timestamp + 24 hours, "Request expired");

        r.approved = true;
        emit Approved(id);
    }

    function executeBurn(uint256 id) external onlyRole(GOVERNOR_ROLE) {
        Request storage r = burnRequests[id];
        require(r.approved, "Not approved");
        require(!r.executed, "Already executed");
        require(block.timestamp <= r.timestamp + 48 hours, "Request expired");
        require(balanceOf(r.target) >= r.amount, "Insufficient balance");

        r.executed = true;
        _burn(r.target, r.amount);
        emit Executed(id);
    }

    // ------------- ADMIN FUNCTIONS -------------
    function setApprover(address newApprover) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newApprover != address(0), "Invalid address");
        address oldApprover = approver;
        approver = newApprover;
        emit ApproverChanged(oldApprover, newApprover);
    }

    function pause() external onlyRole(GOVERNOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(GOVERNOR_ROLE) {
        _unpause();
    }
}

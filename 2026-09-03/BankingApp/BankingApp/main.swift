// ============================================================
// MODULE 4: Swift Programming Fundamentals
// LAB — PNC Banking Domain Model
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// OVERVIEW
// You are building the Swift data model layer for the PNC Mobile
// Banking application. This layer will be carried forward into
// Modules 6, 7, and 8 as the foundation of the real application.
//
// Every type you define here uses the Swift features from all
// three days of this module. Take time to read the full spec
// before writing any code.
//
// ESTIMATED TIME: 90–120 minutes
//
// ============================================================
// LAB SPEC
// ============================================================
//
// You will build five interconnected Swift types:
//
//   1. TransactionType enum
//   2. TransactionStatus enum
//   3. Transaction struct
//   4. Account class
//   5. AccountAnalytics struct
//
// And three protocols:
//
//   A. Summarizable       — any type that can produce a summary string
//   B. AccountOperations  — deposit, withdraw, transfer
//   C. AnalyticsProvider  — compute basic financial metrics
//
// The lab ends with an error handling system and a generic
// result reporting function that ties everything together.
//
// Read each section completely before implementing it.
// ============================================================

import Foundation


// ============================================================
// SECTION 1: Enumerations
// ============================================================

// TODO 1A: TransactionType
// Conform to: String, CaseIterable, Codable
// Cases:     credit, debit, transfer, fee
// Add computed property: isExpense: Bool
//   → true for .debit and .fee, false otherwise
enum TransactionType: String, CaseIterable, Codable {
    case credit = "credit"
    case debit = "debit"
    case transfer = "transfer"
    case fee = "fee"
    
    var isExpense: Bool {
        switch self {
        case .debit: return true
        case .fee: return true
        default: return false
        }
    }
}


// TODO 1B: TransactionStatus
// Conform to: String, Codable
// Cases:     pending, completed, failed, cancelled
// Add computed property: isTerminal: Bool
//   → true for .completed, .failed, .cancelled
//   → false for .pending (can still change)
enum TransactionStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    var isTerminal: Bool {
        switch self {
        case .completed: return true
        case .failed: return true
        case .cancelled: return true
        case .pending: return false
        }
    }
}


// ============================================================
// SECTION 2: Transaction Struct
// ============================================================

// TODO 2: Define struct Transaction conforming to:
//   Identifiable, Codable, Equatable, Hashable, Summarizable (see Section 4A)
//
// Stored properties:
//   id: String                (unique identifier, default to UUID().uuidString)
//   date: Date
//   amount: Double            (always positive — type determines direction)
//   description: String
//   type: TransactionType
//   status: TransactionStatus (default: .completed)
//   category: String?
//   merchantName: String?
//
// Computed properties:
//   formattedAmount: String
//     → "-$X.XX" for expenses (type.isExpense == true)
//     → "+$X.XX" for income/credit
//
//   formattedDate: String
//     → Use DateFormatter with dateStyle: .medium, timeStyle: .short
//
//   resolvedCategory: String
//     → Returns category if non-nil, "Uncategorized" otherwise
//
// Custom initializer (all params except id, status, category, merchantName
// should be required; the rest should have defaults):
//   init(date:amount:description:type:status:category:merchantName:)
struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {
    let id: String
    let date: Date
    let amount: Double
    var description: String
    let type: TransactionType
    var status: TransactionStatus = .completed
    let category: String?
    let merchantName: String?
    
    var formattedAmount: String {
        let sign = type.isExpense ? "-" : "+"
        return "\(sign)$\(String(format: "%.2f", abs(amount)))"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var resolvedCategory: String {
        category ?? "Uncategorized"
    }
    
    var summary: String {
        let merchantSuffix = merchantName.map { " - \($0)" } ?? ""
        return "[\(resolvedCategory)] \(description): \(formattedAmount) on \(formattedDate)\(merchantSuffix)"
    }
    
    init(id: String = UUID().uuidString, date: Date, amount: Double, description: String, type: TransactionType, status: TransactionStatus = .completed, category: String? = nil, merchantName: String? = nil) {
        self.id = id
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    }
}


// ============================================================
// SECTION 3: Account Class
// ============================================================

// TODO 3A: Define protocol AccountOperations (see Section 4B)
// before defining Account, because Account will conform to it.
// (Define the protocol in Section 4B, then add conformance to Account here)


// TODO 3B: Define class BankAccount conforming to:
//   Identifiable, AccountOperations, Summarizable
//
// Stored properties:
//   id: String
//   accountNumber: String
//   accountType: String          (e.g., "CHECKING", "SAVINGS")
//   nickname: String?
//   var balance: Double
//   var availableBalance: Double
//   let currency: String         (default "USD")
//   let isActive: Bool           (default true)
//   var transactions: [Transaction]
//
// Computed properties:
//   displayName: String          → nickname if non-nil, else accountType.capitalized
//   maskedAccountNumber: String  → "****" + last 4 digits
//   formattedBalance: String     → "$X.XX"
//   recentTransactions: [Transaction]  → last 5, sorted by date descending
//   pendingCount: Int            → count of transactions with status .pending
//
// Designated initializer:
//   init(id:accountNumber:accountType:nickname:initialBalance:currency:isActive:)
//
// Implement AccountOperations (see Section 4B for the protocol requirements).
// Use the AccountError enum from Section 4C.
//
// Also add:
//   func addTransaction(_ transaction: Transaction)
//     → appends to transactions AND updates balance:
//       if transaction.type.isExpense: balance -= transaction.amount
//       else:                          balance += transaction.amount
//       Update availableBalance to match balance.
class BankAccount: Identifiable, AccountOperations, Summarizable {
    let id: String
    let accountNumber: String
    let accountType: String
    let nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String
    let isActive: Bool
    var transactions: [Transaction]
    
    var displayName: String {
        return nickname ?? accountType.capitalized
    }
    
    var maskedAccountNumber: String {
        return "****" + (String(accountNumber.suffix(4)))
    }
    
    var formattedBalance: String {
        return "$\(String(format: "%.2f", balance))"
    }
    
    var recentTransactions: [Transaction] {
        transactions.sorted { $0.date > $1.date }.prefix(5).map { $0 }
    }
    
    var pendingCount: Int {
        transactions.filter { $0.status == .pending }.count
    }
    
    var summary: String {
        "\(displayName) \(maskedAccountNumber): \(formattedBalance)"
    }
    
    init(id: String, accountNumber: String, accountType: String, nickname: String?, initialBalance: Double, currency: String = "USD", isActive: Bool = true) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = initialBalance
        self.availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
        self.transactions = []
    }
    
    func deposit(amount: Double) throws {
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard isActive else { throw AccountOperationsError.accountInactive }
        balance += amount
        availableBalance = balance
    }
    
    func withdraw(amount: Double) throws {
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard isActive else { throw AccountOperationsError.accountInactive }
        guard amount <= availableBalance else {
            throw AccountOperationsError.insufficientFunds(available: availableBalance, required: amount)
        }
        balance -= amount
        availableBalance = balance
    }
    
    func transfer(amount: Double, to recipientAccount: BankAccount) throws {
        guard recipientAccount.id != id else { throw AccountOperationsError.transferToSameAccount }
        try withdraw(amount: amount)
        try recipientAccount.deposit(amount: amount)
    }
    
    func addTransaction(_ transaction: Transaction) {
        if transaction.type.isExpense {
            balance -= transaction.amount
        } else {
            balance += transaction.amount
        }
        availableBalance = balance
        transactions.append(transaction)
    }
}


// ============================================================
// SECTION 4: Protocols
// ============================================================

// TODO 4A: Summarizable protocol
//   Required: var summary: String { get }
//   Default implementation via extension: func printSummary() — prints summary
protocol Summarizable {
    var summary: String { get }
}

extension Summarizable {
    func printSummary() {
        print(summary)
    }
}


// TODO 4B: AccountOperations protocol
//   func deposit(amount: Double) throws
//   func withdraw(amount: Double) throws
//   func transfer(amount: Double, to destination: BankAccount) throws
//
// These methods throw AccountOperationsError (define in Section 4C).
protocol AccountOperations {
    func deposit(amount: Double) throws
    func withdraw(amount: Double) throws
    func transfer(amount: Double, to destination: BankAccount) throws
}


// TODO 4C: AccountOperationsError enum conforming to LocalizedError
// Cases:
//   invalidAmount
//   insufficientFunds(available: Double, required: Double)
//   accountInactive
//   transferToSameAccount
//   dailyLimitExceeded(limit: Double)
//
// Each case should have a meaningful errorDescription.
enum AccountOperationsError: Error, LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount. Should be greater than 0."
        case .accountInactive:
            return "Account is inactive."
        case .transferToSameAccount:
            return "Cannot transfer to the same account."
        case .dailyLimitExceeded(limit: let limit):
            return "Daily limit exceeded: $\(String(format: "%.2f", limit))"
        case .insufficientFunds(available: let available, required: let required):
            return "Insufficient funds: only $\(String(format: "%.2f", available)) available, need $\(String(format: "%.2f", required))."
        }
    }
}


// ============================================================
// SECTION 5: Analytics
// ============================================================

// TODO 5A: AnalyticsProvider protocol
//   var totalCredits: Double { get }
//   var totalDebits: Double { get }
//   var netFlow: Double { get }         // credits - debits
//   var largestTransaction: Transaction? { get }
//   func monthlyTotal(month: Int, year: Int) -> Double
//   func transactionsByCategory() -> [String: [Transaction]]
protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }
    var largestTransaction: Transaction? { get }
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}


// TODO 5B: AccountAnalytics struct
// Stored property: transactions: [Transaction]
// Conform to AnalyticsProvider.
// Implement each requirement.
//
// Tips:
//   totalCredits: use .filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
//   transactionsByCategory: group by resolvedCategory using a Dictionary
//     (hint: use Dictionary(grouping:by:))
//   monthlyTotal: filter by Calendar.current month/year components and sum expense amounts
struct AccountAnalytics: AnalyticsProvider {
    var transactions: [Transaction]
    
    var totalCredits: Double {
        return transactions.filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    var totalDebits: Double {
        return transactions.filter { $0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    var netFlow: Double {
        return totalCredits - totalDebits
    }
    
    var largestTransaction: Transaction? {
        return transactions.max(by: { $0.amount < $1.amount })
    }
    
    func transactionsByCategory() -> [String: [Transaction]] {
        Dictionary(grouping: transactions, by: \.resolvedCategory)
    }
    
    func monthlyTotal(month: Int, year: Int) -> Double {
        transactions
            .filter { transaction in
                let components = Calendar.current.dateComponents([.month, .year], from: transaction.date)
                return components.month == month && components.year == year && transaction.type.isExpense
            }
            .reduce(0) { $0 + $1.amount }
    }
}


// ============================================================
// SECTION 6: Generic Result Reporter
// ============================================================

// TODO 6: Write a generic function:
//   func reportResults<T: Summarizable>(_ items: [T], title: String)
//
// It should:
//   1. Print a header line: "=== [title] ==="
//   2. Print the item count: "[N] items"
//   3. Call printSummary() on each item
//   4. Print a footer: "=== End of [title] ==="
//
// The function must work for any type conforming to Summarizable —
// including both Transaction and BankAccount.

func reportResults<T: Summarizable>(_ items: [T], title: String) {
    print("=== \(title) ===")
    print("\(items.count) items")
    items.forEach { $0.printSummary() }
    print("=== End of \(title) ===")
}


// ============================================================
// SECTION 7: INTEGRATION TEST — Tie it all together
// ============================================================

// TODO 7: Write a function named runlabDemo() that does the following:

// 7A: Create at least two BankAccount instances:
//   - A checking account with $3,500 initial balance
//   - A savings account with $12,000 initial balance

// 7B: Create at least five Transaction instances across different types
//   and add them to the checking account using addTransaction(_:)
//   Include: one credit, two debits, one fee, one transfer
//   Verify the balance updates correctly after each addition.

// 7C: Demonstrate error handling:
//   - Try to withdraw more than the available balance → catch insufficientFunds
//   - Try to deposit a negative amount → catch invalidAmount
//   - Try to transfer to the same account → catch transferToSameAccount
//   Print the localized error description for each caught error.

// 7D: Create an AccountAnalytics instance with the checking account's transactions.
//   Print:
//   - Total credits
//   - Total debits
//   - Net flow
//   - The description and amount of the largest transaction
//   - The transactions grouped by category (print each category and count)

// 7E: Call reportResults with the checking account's transactions, title: "Checking Transactions"
//   Call reportResults with [checkingAccount, savingsAccount], title: "All Accounts"

// 7F: Demonstrate value vs. reference semantics:
//   Copy one Transaction (struct) into a new variable. Modify the copy's description.
//   Show the original is unchanged.
//   Assign the checking account (class) to a new variable. Deposit $100 through the alias.
//   Show both variables reflect the updated balance.

// TODO: Call runlabDemo() at the bottom of the file.

func runlabDemo() {
    let checkingAccount1 = BankAccount(id: "ACC-01", accountNumber: "3789324067", accountType: "CHECKING", nickname: "Checking Acct", initialBalance: 3_500)
    let savingsAccount1 = BankAccount(id: "ACC-02", accountNumber: "8578490723", accountType: "SAVINGS", nickname: "Savings Acct", initialBalance: 12_000)
    
    let transactions: [Transaction] = [
        Transaction(date: Date(), amount: 105.73, description: "Grocery store", type: .debit, category: "Payment", merchantName: "Giant Eagle"),
        Transaction(date: Date(), amount: 630.21, description: "Paycheck", type: .credit, category: "Income", merchantName: "BIG Corp"),
        Transaction(date: Date(), amount: 22.53, description: "Gas station", type: .debit, category: "Payment", merchantName: "Sheetz"),
        Transaction(date: Date(), amount: 10.00, description: "Maintenance fee", type: .fee, category: "Fees", merchantName: "Anonymous Apartments"),
        Transaction(date: Date(), amount: 500.0, description: "Money transfer", type: .transfer, category: "Transfer")
    ]
    
    let divider = "---------------------------------------"
    
    print("Initial checking account balance: \(checkingAccount1.formattedBalance)")
    print("Initial savings account balance: \(savingsAccount1.formattedBalance)")
    
    print(divider)
    
    for transaction in transactions {
        checkingAccount1.addTransaction(transaction)
        print("Balance: \(checkingAccount1.formattedBalance)")
    }
    
    print(divider)
    
    let errorTests: [(label: String, operation: () throws -> Void)] = [
            ("Withdraw", { try checkingAccount1.withdraw(amount: 10_000) }),
            ("Deposit", { try checkingAccount1.deposit(amount: -99) }),
            ("Transfer", { try checkingAccount1.transfer(amount: 350, to: checkingAccount1) })
    ]
    
    errorTests.forEach { errorTest in
        do {
            try errorTest.operation()
        } catch let error as AccountOperationsError {
            print("Error: \(error.errorDescription ?? "Unknown error")")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    print(divider)
    
    let analytics = AccountAnalytics(transactions: checkingAccount1.transactions)
    
    print("Total credits: $\(String(format: "%.2f", analytics.totalCredits))")
    print("Total debits: $\(String(format: "%.2f", analytics.totalDebits))")
    print("Net flow: $\(String(format: "%.2f", analytics.netFlow))")
    
    if let largestTransaction = analytics.largestTransaction {
        print("Largest transaction: \(largestTransaction.description): \(largestTransaction.formattedAmount)")
    }
    print("Transactions grouped by category:")
    for (category, txns) in analytics.transactionsByCategory() {
            print("-\(category): \(txns.count)")
    }
    
    print(divider)
    
    reportResults(checkingAccount1.transactions, title: "Checking Transactions")
    reportResults([checkingAccount1, savingsAccount1], title: "All Accounts")
    
    print(divider)
    
    let oldTransaction = transactions[0]
    var newTransaction = oldTransaction
    newTransaction.description = "Food"
    
    print("Old transaction: \(oldTransaction.summary)")
    print("Old description: \(oldTransaction.description)")
    
    print("New transaction: \(newTransaction.summary)")
    print("New description: \(newTransaction.description)")
    
    print(divider)
    
    print("checkingAccount1 balance (before deposit): \(checkingAccount1.formattedBalance)")
    
    let checkingAlias = checkingAccount1
    try? checkingAlias.deposit(amount: 100)
    print("checkingAccount1 balance: \(checkingAccount1.formattedBalance)")
    print("checkingAlias balance: \(checkingAlias.formattedBalance)")
}

runlabDemo()


// ============================================================
// END OF LAB
// ============================================================
//
// SELF-ASSESSMENT CHECKLIST
// Before submitting, verify:
//   [ ] All five types compile without warnings
//   [ ] runlabDemo() runs to completion with no crashes
//   [ ] Each error case in 7C is handled and prints a clear message
//   [ ] Struct copy semantics are correctly demonstrated in 7F
//   [ ] Class reference semantics are correctly demonstrated in 7F
//   [ ] reportResults works for both Transaction and BankAccount
//   [ ] Analytics produce correct totals matching your transactions
// ============================================================

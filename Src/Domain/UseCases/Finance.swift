import Foundation

struct AccountBalance: Equatable, Sendable {
    let accountID: UUID
    let balance: Decimal
}

struct BudgetProgress: Equatable, Sendable {
    let budgetID: UUID
    let spent: Decimal
    let limit: Decimal

    var ratio: Decimal {
        guard limit > .zero else {
            return spent > .zero ? 1 : .zero
        }
        return spent / limit
    }
}

enum Finance {
    static func balance(for account: Account, transactions: [Transaction]) -> Decimal {
        transactions
            .filter { $0.account.id == account.id || $0.transferAccount?.id == account.id }
            .reduce(account.openingBalance) { balance, transaction in
                guard transaction.type != .transfer else {
                    return transaction.transferAccount?.id == account.id
                        ? balance + transaction.amount
                        : balance - transaction.amount
                }
                guard transaction.account.id == account.id else {
                    return balance
                }
                return balance + transaction.signedAmount
            }
    }

    static func balances(
        for accounts: [Account],
        transactions: [Transaction]
    ) -> [AccountBalance] {
        accounts.map {
            AccountBalance(
                accountID: $0.id,
                balance: balance(for: $0, transactions: transactions)
            )
        }
    }

    static func netWorth(accounts: [Account], transactions: [Transaction]) -> Decimal {
        accounts.reduce(.zero) { total, account in
            let currentBalance = balance(for: account, transactions: transactions)
            return total + (account.type.isLiability ? -currentBalance : currentBalance)
        }
    }

    static func expenseTotal(
        transactions: [Transaction],
        from startDate: Date,
        through endDate: Date,
        categoryID: UUID? = nil
    ) throws -> Decimal {
        guard startDate <= endDate else {
            throw DomainError.invalidDateRange
        }
        return transactions
            .filter {
                $0.type == .expense &&
                    $0.occurredAt >= startDate &&
                    $0.occurredAt <= endDate &&
                    (categoryID == nil || $0.category?.id == categoryID)
            }
            .reduce(.zero) { $0 + $1.amount }
    }

    static func budgetProgress(
        for budget: Budget,
        transactions: [Transaction]
    ) throws -> BudgetProgress {
        let spent = try expenseTotal(
            transactions: transactions,
            from: budget.startDate,
            through: budget.endDate,
            categoryID: budget.category?.id
        )
        return BudgetProgress(budgetID: budget.id, spent: spent, limit: budget.amount)
    }
}
